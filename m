From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net 0/3] namespace collision fix and update FW version
 check on cxgb4
Date: Mon, 30 Dec 2013 12:46:42 +0530
Message-ID: <20131230071641.GA11909@hariprasad-pc>
References: <1387798320-29255-1-git-send-email-hariprasad@chelsio.com>
 <20131229.223021.1188738781129653670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<nirranjan@chelsio.com>, <kumaras@chelsio.com>,
	<santosh@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8956 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab3L3HQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 02:16:14 -0500
Content-Disposition: inline
In-Reply-To: <20131229.223021.1188738781129653670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 29, 2013 at 22:30:21 -0500, David Miller wrote:
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Mon, 23 Dec 2013 17:01:57 +0530
> 
> > Patch 1/3 (cxgb4: make functions static and remove dead code) was provided by
> > Stephen Hemminger on netdev mailing list.
> > http://www.spinics.net/lists/linux-rdma/msg18148.html
> 
> Such cleanups really are not appropriate for 'net'.

Ok.
Sorry, my bad.

I will re-base these patches on top of net-next and re-submit.


Thanks,
Hari.
