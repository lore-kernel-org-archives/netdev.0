From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: Ax88190 specs (was 8390 specs)
Date: Sat, 18 Dec 2004 01:41:14 +0100
Message-ID: <41C37CAA.3030608@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: marcelo.tosatti@cyclades.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tosatti wrote:

> I'm having a problem with a Linksys EtherFast card (driven by axnet_cs), 
> where the interrupt status reports ENISR_RX_ERR (receive error) 
> under load.
> 
> I would like to know more details about this status bit, 
> what can causes it to be turned on, etc.
> 
> Do you know where I can find 8390 specs?
> 
> 8390.c mentions
> Sources:
> The National Semiconductor LAN Databook, and the 3Com 3c503 databook.
> 
> But I can't find those available in either Google search or the 
> National Semiconductor website.
> 
> Any information or pointers are welcome, thanks!


Maybe these

   http://www.asix.com.tw/download/Ax88190.pdf
   http://www.asix.com.tw/download/Ax88190a.pdf

can help you. More docs at -> http://www.asix.com.tw/download_datasheet.htm

regards,
-- 
TLOZ OOT: worse than drugs.
