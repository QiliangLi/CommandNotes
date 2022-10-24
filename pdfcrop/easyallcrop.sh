#!/bin/bash
######################################################################
##                                                                  ##
##   遍历指定目录获取当前目录下指定后缀（如txt和ini）的文件名            ##
##                                                                  ##
######################################################################
 
##递归遍历
traverse_dir()
{
    filepath=$1
    
    for file in `ls -a $filepath`
    do
        if [ -d ${filepath}/$file ]
        then
            if [[ $file != '.' && $file != '..' ]]
            then
                #递归
                traverse_dir ${filepath}/$file
            fi
        else
            #调用查找指定后缀文件
            check_suffix ${filepath}/$file
        fi
    done
}
 

check_suffix()
{
    file=$1
	
	# ##获取后缀为txt或ini的文件    
 #    if [ "${file##*.}"x = "txt"x ] || [ "${file##*.}"x = "ini"x ];then
 #        echo $file
 #    fi

 	##获取后缀为pdf的文件，并pdfcrop所有的pdf文件   
    if [ "${file##*.}"x = "pdf"x ];then
        echo $file

        pdfpath=${file}
		# filename=${pdfpath##*/}
		# dirpath=${pdfpath%/*}
		filename=$(basename ${pdfpath})
		dirpath=$(dirname ${pdfpath})
		remotedir='/home/hadoop/lql/'
		remotepath=${remotedir}${filename}
		# echo ${pdfpath} ${filename} ${dirpath} ${remotedir} ${remotepath}
		# echo "~/bin/pdfcrop ${remotepath} ${remotepath}"

		scp ${pdfpath} hadoop@n19:${remotedir}
		ssh hadoop@n19 "~/bin/pdfcrop ${remotepath} ${remotepath}"
		scp hadoop@n19:${remotepath} ${dirpath}
    fi
}


traverse_dir $1