#!/usr/bin/ruby

path = ARGV[0]
path = "/Users/tim/Dev/depop-ios/Garage/Garage/"
if !path
    abort("No path supplied")
end

ObjcClass = Struct.new(:name, :path)

def getClasses(path)
    classes = []
    Dir.glob(path + "**/*.[hm]") do |filepath|
        if !filepath.include? ".framework"
            text = File.read(filepath, :encoding => 'utf-8')
            text.scan(/@interface\s*(\w*?)\W/).each do |match|
                classes.push(ObjcClass.new(match[0], filepath))
            end
        end
    end
    return classes
end

def getUnusedClasses(path, classes)
    unused = []
    for objcClass in classes
        if !isClassUsed(path, objcClass)
            unused.push(objcClass)
        end
    end
    return unused
end

def isClassUsed(path, objcClass)
    Dir.glob(path + "**/*.[hm]") do |filepath|
        if objcClass.name != File.basename(filepath, ".*")
            text = File.read(filepath, :encoding => 'utf-8')
            match = /#{objcClass.name}/.match(text)
            if match
                return true
            end
        end
    end
    return false
end

def deleteClasses(classes)
    for objcClass in classes
        puts ("Deleting " + objcClass.path.chop.chop)
        File.delete(objcClass.path.chop.concat("h"))
        File.delete(objcClass.path.chop.concat("m"))
    end
end

puts "Finding classes"
classes = getClasses(path)
puts("Found " + classes.count.to_s + " classes")
unused = getUnusedClasses(path, classes)
puts("Found " + unused.count.to_s + " unused classes")
deleteClasses(unused)
