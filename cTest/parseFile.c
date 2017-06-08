#include <stdio.h>  
#include "libxml/parser.h"  
#include "libxml/tree.h"  
  
int parseFile(char* fileName)  
{  
    xmlDocPtr doc;              //定义解析文档指针  
    xmlNodePtr curNode;         //定义节点指针（在各个节点之间移动）  
    //例如：编译格式为g++ modify_node.cpp -o modify_node -I /usr/local/include/libxml2/  -L /usr/local/lib -lxml2，生成可执行文件modify_node，运行时：./modify_node log4crc（此处log4crc为要修改的xml文档）  
  
    printf("........start........\n");  
    doc = xmlReadFile(fileName, "utf-8", XML_PARSE_RECOVER);   //解析文档  
    if (NULL == doc)  
    {  
        fprintf(stderr, "Document not parsed successfully.\n");  
          
        return -1;  
    }  
  
    curNode = xmlDocGetRootElement(doc);        //确定文档根元素  
    if (NULL == curNode)  
    {  
        fprintf(stderr, "Empty Document.\n");  
        xmlFreeDoc(doc);        //释放文件  
  
        return -1;  
    }  
  
    if (xmlStrcmp(curNode->name, (const xmlChar*)"note"))   //确认根元素是否为“log4c”  
    {  
        fprintf(stderr, "Document of wrong type. root node != note");  
        xmlFreeDoc(doc);  
  
        return -1;  
    }  
  
    curNode = curNode->xmlChildrenNode;  
    xmlNodePtr propNode = curNode;  
    while (NULL != curNode)     //遍历所有节点  
    {  
        //获取名称为category的节点  
        if (!xmlStrcmp(curNode->name, (const xmlChar*)"category"))  
        {  
            //查找带有属性name的节点  
            if (xmlHasProp(curNode, BAD_CAST "name"))  
            {  
                propNode = curNode;  
            }  
  
            //查找属性name为WLAN_Console的节点  
            xmlAttrPtr attrPtr = propNode->properties;  
            while (NULL != attrPtr)     //遍历所有名称为category的节点  
            {  
                if (!xmlStrcmp(attrPtr->name, (const xmlChar*)"name"))   //找到有name属性到节点  
                {  
                    //查找属性为name的值的节点  
                    xmlChar* szPropity = xmlGetProp(propNode, (const xmlChar*)"name");  
                    if (!xmlStrcmp((const xmlChar*)szPropity, (const xmlChar*)"WLAN_Console"))  
                    {  
                        xmlAttrPtr setAttrPtr = propNode->properties;  
                        while (NULL != setAttrPtr)  
                        {  
                            //设置属性priority的值  
                            xmlSetProp(propNode, (const xmlChar*)"priority", (const xmlChar*)"debug");  
              
                            setAttrPtr = setAttrPtr->next;  
                        }  
                    }  
                }  
                attrPtr = attrPtr->next;  
            }     
        }  
        curNode = curNode->next;  
    }  
      
    //保存文档到原文档中  
    xmlSaveFile("config2.xml", doc);  
  
    printf("...........OK............\n");  
  
    return 0;  
} 
