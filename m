From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [TG3]: Add tagged status support
Date: Fri, 6 May 2005 09:12:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505060908200.29330@linux.site>
References: <20050505211735.3829cff2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505211735.3829cff2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, 5 May 2005, David S. Miller wrote:

> .....
> I also removed the MAILBOX readback in the normal interrupt handling
> paths.  Network processing overhead minded folks, particular the SGI
> NUMA people (hint hint) should really really check out this patch :-)
> 

I'll put it on my to-do list to check out this and other recent tg3 
patches. It may be a week or so until I can get to this, however.

--
Arthur
