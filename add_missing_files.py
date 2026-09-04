import uuid, re

def gen_id():
    return uuid.uuid4().hex[:24].upper()

views = [
    "QRCodeScannerView.swift",
    "TeamQRInviteView.swift",
    "MyQRProfileView.swift",
    "ClientLedgerView.swift",
    "InvoiceReceiptView.swift",
    "LeaderboardView.swift"
]

models = [
    "CSVExporter.swift",
    "Client+Extensions.swift",
    "QRGenerator.swift"
]

with open('MatchSplitter.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

build_files_chunk = ""
file_refs_chunk = ""
views_children_chunk = ""
models_children_chunk = ""
sources_files_chunk = ""

for v in views:
    f_id = gen_id()
    bf_id = gen_id()
    build_files_chunk += f"\t\t{bf_id} /* {v} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_id} /* {v} */; }};\n"
    file_refs_chunk += f"\t\t{f_id} /* {v} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{v}\"; sourceTree = \"<group>\"; }};\n"
    views_children_chunk += f"\t\t\t\t{f_id} /* {v} */,\n"
    sources_files_chunk += f"\t\t\t\t{bf_id} /* {v} in Sources */,\n"

for m in models:
    f_id = gen_id()
    bf_id = gen_id()
    build_files_chunk += f"\t\t{bf_id} /* {m} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_id} /* {m} */; }};\n"
    file_refs_chunk += f"\t\t{f_id} /* {m} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{m}\"; sourceTree = \"<group>\"; }};\n"
    models_children_chunk += f"\t\t\t\t{f_id} /* {m} */,\n"
    sources_files_chunk += f"\t\t\t\t{bf_id} /* {m} in Sources */,\n"

content = content.replace("/* End PBXBuildFile section */", build_files_chunk + "/* End PBXBuildFile section */")
content = content.replace("/* End PBXFileReference section */", file_refs_chunk + "/* End PBXFileReference section */")

content = re.sub(
    r'(/\* Views \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \()',
    r'\g<1>\n' + views_children_chunk.rstrip('\n'),
    content
)

content = re.sub(
    r'(/\* Models \*/ = \{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \()',
    r'\g<1>\n' + models_children_chunk.rstrip('\n'),
    content
)

content = re.sub(
    r'(/\* Sources \*/ = \{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = [0-9]+;\n\t\t\tfiles = \()',
    r'\g<1>\n' + sources_files_chunk.rstrip('\n'),
    content
)

with open('MatchSplitter.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)
print("Added files to pbxproj successfully!")
