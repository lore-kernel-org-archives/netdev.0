From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: 8390 specs
Date: Thu, 25 Nov 2004 06:58:29 -0200
Message-ID: <20041125085829.GA15595@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, becker@scyld.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm having a problem with a Linksys EtherFast card (driven by axnet_cs), 
where the interrupt status reports ENISR_RX_ERR (receive error) 
under load.

I would like to know more details about this status bit, 
what can causes it to be turned on, etc.

Do you know where I can find 8390 specs?

8390.c mentions
Sources:
The National Semiconductor LAN Databook, and the 3Com 3c503 databook.

But I can't find those available in either Google search or the 
National Semiconductor website.

Any information or pointers are welcome, thanks!
