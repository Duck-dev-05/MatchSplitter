import uuid, re, sys
def gen_id():
    return uuid.uuid4().hex[:24].upper()

with open('MatchSplitter.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Make backup
with open('MatchSplitter.xcodeproj/project.pbxproj.bak', 'w') as f:
    f.write(content)

pkg_ref_id = gen_id()
pkg_prod_id = gen_id()
build_file_id = gen_id()
pkg_prod_swift_id = gen_id()
build_file_swift_id = gen_id()

# 1. Add XCRemoteSwiftPackageReference
remote_pkg = f'''
/* Begin XCRemoteSwiftPackageReference section */
		{pkg_ref_id} /* XCRemoteSwiftPackageReference "GoogleSignIn" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/google/GoogleSignIn-iOS.git";
			requirement = {{
				kind = upToNextMajorVersion;
				minimumVersion = 7.1.0;
			}};
		}};
/* End XCRemoteSwiftPackageReference section */
'''
content = content.replace('/* Begin XCBuildConfiguration section */', remote_pkg.strip() + '\n\n/* Begin XCBuildConfiguration section */')

# 2. Add XCSwiftPackageProductDependency
prod_dep = f'''
/* Begin XCSwiftPackageProductDependency section */
		{pkg_prod_id} /* GoogleSignIn */ = {{
			isa = XCSwiftPackageProductDependency;
			package = {pkg_ref_id} /* XCRemoteSwiftPackageReference "GoogleSignIn" */;
			productName = GoogleSignIn;
		}};
		{pkg_prod_swift_id} /* GoogleSignInSwift */ = {{
			isa = XCSwiftPackageProductDependency;
			package = {pkg_ref_id} /* XCRemoteSwiftPackageReference "GoogleSignIn" */;
			productName = GoogleSignInSwift;
		}};
/* End XCSwiftPackageProductDependency section */
'''
content = content.replace('/* Begin XCBuildConfiguration section */', prod_dep.strip() + '\n\n/* Begin XCBuildConfiguration section */')

# 3. Add to PBXProject
content = re.sub(r'(isa = PBXProject;.*?mainGroup = A100000000000000000000032 /\* \*/;)', 
                 r'\g<1>\n			packageReferences = (\n				' + pkg_ref_id + r' /* XCRemoteSwiftPackageReference "GoogleSignIn" */,\n			);', 
                 content, flags=re.DOTALL)

# 4. Add to PBXNativeTarget packageProductDependencies
content = re.sub(r'(isa = PBXNativeTarget;.*?name = MatchSplitter;)',
                 r'\g<1>\n			packageProductDependencies = (\n				' + pkg_prod_id + r' /* GoogleSignIn */,\n				' + pkg_prod_swift_id + r' /* GoogleSignInSwift */,\n			);',
                 content, flags=re.DOTALL)

# 5. Add to PBXFrameworksBuildPhase
content = re.sub(r'(isa = PBXFrameworksBuildPhase;.*?files = \()',
                 r'\g<1>\n				' + build_file_id + r' /* GoogleSignIn in Frameworks */,\n				' + build_file_swift_id + r' /* GoogleSignInSwift in Frameworks */,',
                 content, flags=re.DOTALL)

# 6. Add PBXBuildFile
build_files = f'''
		{build_file_id} /* GoogleSignIn in Frameworks */ = {{isa = PBXBuildFile; productRef = {pkg_prod_id} /* GoogleSignIn */; }};
		{build_file_swift_id} /* GoogleSignInSwift in Frameworks */ = {{isa = PBXBuildFile; productRef = {pkg_prod_swift_id} /* GoogleSignInSwift */; }};
'''
content = content.replace('/* End PBXBuildFile section */', build_files.strip() + '\n/* End PBXBuildFile section */')

with open('MatchSplitter.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)
print("Modified pbxproj successfully!")
