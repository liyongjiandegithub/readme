#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>
#include <string.h> 


int printNode(xmlNodePtr curNode)
{
    //printf("%s %d curNode %p\n",__FUNCTION__,__LINE__,curNode);
    while(curNode != NULL)
    {
        if(curNode->type == XML_ELEMENT_NODE)
        {
            xmlChar* content;
            content = xmlNodeGetContent(curNode);
            printf("%d curNode %p [type %d] name %s Content %s\n",__LINE__,curNode, curNode->type, curNode->name, content);
            xmlFree(content);
            if (!xmlStrcmp(curNode->name, (const xmlChar*)"input_PCR_PID"))  
            {  
                xmlChar newContent[]="1000";
                xmlNodeSetContent(curNode, newContent);
                printf("%d curNode %p name %s Content =%s\n",__LINE__,curNode, curNode->name, newContent);
            }
            if(curNode->children != NULL)
            {
                printNode(curNode->children);
            }
        }
        //printf("%d curNode %p type %d name %s\n",__LINE__,curNode, curNode->type, curNode->name);
        curNode = curNode->next;
    }
}

int parseBuffer()
{
    xmlDocPtr pdoc;
    xmlNodePtr curNode;
    xmlChar* content;
    printf("\n%s\n",__FUNCTION__);
#if 1
    char buffer[] = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\
<note>\
<state>George</state>\
<to>George</to>\
<from>John</from>\
<heading>Reminder</heading>\
<body>Don't forget the meeting!</body>\
<input_video_PID>1000</input_video_PID>\
<input_PCR_PID>1001</input_PCR_PID>\
<input_audio_PID>1002</input_audio_PID>\
</note> ";
    int size = strlen(buffer);
    pdoc = xmlParseMemory(buffer, size);
    if( pdoc == NULL)
    {
         printf("Fail to parse XML buffer.\n");
    }
#else
    //pdoc = xmlParseFile("config.xml");
    pdoc = xmlReadFile("config.xml", "UTF-8", XML_PARSE_NOBLANKS);
    if( pdoc == NULL )
    {
         printf("Fail to parse XML file.\n");
    }
#endif
    curNode = xmlDocGetRootElement(pdoc); 
    if (NULL == curNode)
    {
       printf("empty document/n");
       xmlFreeDoc(pdoc);
       return -1;
    }    
    if (xmlStrcmp(curNode->name, BAD_CAST "note"))
    {
       printf("document of the wrong type, root node != note %s\n",curNode->name);
       xmlFreeDoc(pdoc);
       return -1;
    }


#if 1
    printNode(curNode->children);
#else
    curNode = curNode->children;
    while(curNode != NULL)
    {
        //printf("%d curNode %p name %s Content =%s\n",__LINE__,curNode, curNode->name, curNode->content);
        content = xmlNodeGetContent(curNode);
        printf("%d curNode %p name %s Content =%s\n",__LINE__,curNode, curNode->name, content);
        if (!xmlStrcmp(curNode->name, (const xmlChar*)"state"))  
        {  
            xmlNodeSetContent(curNode, content);
        }

        xmlFree(content);
        curNode = curNode->next;
    }
#endif
    int filesize;
    //filesize = xmlSaveFormatFileEnc("config.xml", pdoc, "gb2312",1);
    filesize = xmlSaveFormatFileEnc("config3.xml", pdoc, "UTF-8",1);
    if(filesize == -1)
    {
         printf("Fail to save XML to file.\n");
    }

    xmlFreeDoc(pdoc);
    return 0; 
}
