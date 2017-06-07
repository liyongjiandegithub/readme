#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>



int main()
{
    xmlDocPtr pdoc;
    xmlNodePtr curNode;
    xmlChar *szKey;
    pdoc = xmlParseFile("config.xml");
    if( pdoc == NULL )
    {
         printf("Fail to parse XML file.\n");
    }
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
    curNode = curNode->children;
    while(curNode != NULL)
    {
       printf("curNode %p name %s Content =%s\n",curNode, curNode->name, curNode->content);
       szKey = xmlNodeGetContent(curNode);
       printf("curNode %p name %s Content =%s\n",curNode, curNode->name, szKey);
       curNode = curNode->next;
    }
    xmlFreeDoc(pdoc);
    return 0; 
}
