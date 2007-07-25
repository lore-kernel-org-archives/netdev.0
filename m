From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] netxen: Load firmware during probe, dma watchdog
 fix.
Date: Wed, 25 Jul 2007 10:29:31 -0400
Message-ID: <46A75E4B.4050504@garzik.org>
References: <20070719091108.839200259@netxen.com>	 <20070719091131.467737478@netxen.com> <46A662D5.3020201@garzik.org> <ab901500707242118q27cb9eddqe69f01275b809b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	Wen Xiong <wenxiong@us.ibm.com>
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38054 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059AbXGYO3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 10:29:36 -0400
In-Reply-To: <ab901500707242118q27cb9eddqe69f01275b809b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dhananjay Phadke wrote:
> Jeff,
> 
> You committed old patch, which I had asked to ignore for two newer patches.
> 
> [PATCH 1/1] netxen: Load firmware during probe, dma watchdog fix.
> 
> is wrong patch that went in, instead please commit:
> 
> [PATCH 1/2] netxen: IMEZ multiport card 2nd port issue, dma watchdog fix
> [PATCH 2/2] netxen: Fix interrupt handling for multiport adapters

Two responses:

1) I never received the two patches you mention.  It helps (though not 
required) to CC me, in addition to sending patches to netdev.

2) Kernel history is fixed in stone, once committed upstream.  Thus, you 
must regenerate your patches based on the fact that old-patch is now 
upstream.

	Jeff



