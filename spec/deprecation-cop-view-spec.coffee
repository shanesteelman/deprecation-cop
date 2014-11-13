{WorkspaceView} = require 'atom'
Grim = require 'grim'
DeprecationCopView = require '../lib/deprecation-cop-view'
path = require 'path'

describe "DeprecationCopView", ->
  deprecationCopView = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('deprecation-cop')
    deprecatedMethod = -> Grim.deprecate("This isn't used")
    deprecatedMethod()

    atom.workspaceView.trigger 'deprecation-cop:view'

    waitsForPromise ->
      activationPromise

    runs ->
      deprecationCopView = atom.workspace.getActivePane().getActiveItem()

  it "displays deprecated methods", ->
    expect(deprecationCopView.html()).toMatch /deprecation-cop package/
    expect(deprecationCopView.html()).toMatch /This isn't used/

  it "displays deprecated selectors", ->
    fakePackageDir = path.join(__dirname, "..", "spec", "fixtures", "package-with-deprecated-selectors")

    # TODO - do this better?
    Package = atom.packages.getActivePackages()[0].constructor
    pack = new Package(fakePackageDir)
    pack.load()
    spyOn(atom.packages, 'getActivePackages').andReturn([pack])
    deprecationCopView.find("button.refresh-selectors").click()

    packageItems = deprecationCopView.find("ul.selectors > li")
    expect(packageItems.length).toBe(1)
    expect(packageItems.eq(0).html()).toMatch /package-with-deprecated-selectors/

    packageDeprecationItems = packageItems.eq(0).find("li.source-file")
    expect(packageDeprecationItems.length).toBe(3)
    expect(packageDeprecationItems.eq(0).text()).toMatch /atom-text-editor/
    expect(packageDeprecationItems.eq(0).find("a").attr("href")).toBe(path.join(fakePackageDir, "menus", "old-menu.cson"))
    expect(packageDeprecationItems.eq(1).text()).toMatch /atom-pane-container/
    expect(packageDeprecationItems.eq(1).find("a").attr("href")).toBe(path.join(fakePackageDir, "keymaps", "old-keymap.cson"))
    expect(packageDeprecationItems.eq(2).text()).toMatch /atom-workspace/
    expect(packageDeprecationItems.eq(2).find("a").attr("href")).toBe(path.join(fakePackageDir, "stylesheets", "old-stylesheet.less"))
