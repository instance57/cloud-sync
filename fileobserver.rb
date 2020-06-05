require 'yaml'  

class Fileobserver
  def initialize
    blackListfile = File.open("fileBlackList.yml", "r")


    @newInventory = {}
    @addList   = {}
    @deletedList  = {} 
    @editList = {}
    @yamlBalckListList = YAML.load(blackListfile.read)
    print @yamlBalckListList

    blackListfile.close
  end

  def getnewinventory(wd = Dir.pwd, printdebug=false)
    @deletedList = @newInventory.clone
    #wd = Dir.pwd
    puts (wd + "good day")
    dirlist = Dir.glob( '**/*', base:wd)
    dirlist.each do |file|
      puts file
      if @newInventory.has_key?(file) == false
        if @yamlBalckListList.include?(wd+"\\"+file) == false
          @addList[file] = File.mtime(file)    
        end 
      end
      @deletedList.delete(file)
    end

    # 

    @newInventory.each do |file ,data|
      #kolla items metadata med dirlists metadata
      begin
        if @newInventory[file] != File.mtime(file)
          @editList[file] = file
          @newInventory[file] = File.mtime(file)
        end
        case printdebug when true
          print(@newInventory[file])
          gets
        end

      rescue
        puts("error. canot find file\ninventory:",@newInventory)
      end      
    end 
    #zxczxc
    #dirlist = what is found
    #@addlist = everything new found i dirlist that is not found in @newInventory
    #@deletedList = @newList - dirlist (resulting in a list with everything that has been deleted
    #@newInventory = @newInventory + @addlist - deletelist
    #
    ### delete on finish... debug code ###
    case printdebug when true
      puts("################################################\n################\ninventory\n################")
      #puts @newInventory
      @newInventory.each do |file|
        puts (file)
      end
      puts("################\nadd\n################")
      
      @addList.each do |file|
        puts (file)
      end
      puts("################\nremove\n################")
      
      @deletedList.each do |file|
        puts (file)
      end
      
      puts("################\nedit\n################")
      @editList.each do |file|
        puts (file)
      end

    end 
      ######################################
    
    
    @deletedList.each do |key, value|
      @newInventory.delete(key)
    
    end
    @addList.each do |key, value|
      @newInventory[key] = value
      #print("added \t",key.to_s,"\t to invetory, with the value of: \t", value.to_s,"\n")
    end
    @addList = {}
    @editList= {}
  end
end


whiteListfile = File.new("whiteList.yml", "r")
@whiteList = YAML.load(whiteListfile.read)
whiteListfile.close
#puts(@whiteList)

instance = Fileobserver.new
while true
  @whiteList.each do |file|
    puts file
    instance.getnewinventory(file , true)
  end
  gets
end