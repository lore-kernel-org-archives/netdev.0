From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 8139too: use netdev_alloc_skb
Date: Wed, 03 Sep 2008 10:24:53 -0400
Message-ID: <48BE9E35.5050006@garzik.org>
References: <1219808113.7135.13.camel@nsl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Lo <kevlo@kevlo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32963 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754830AbYICOY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:24:57 -0400
In-Reply-To: <1219808113.7135.13.camel@nsl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Lo wrote:
> Hi,
> 
> This patch uses netdev_alloc_skb. This sets skb->dev and allows 
> arch specific allocation. Also cleanup the alignment code.
> 
> Tested on x86_64.
> 
> Signed-off-by:	Kevin Lo <kevlo@kevlo.org>

applied this, and the other two


