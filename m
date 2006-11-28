From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] add auditing to ipsec
Date: Tue, 28 Nov 2006 00:08:07 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611280007220.3617@d.namei>
References: <200611272226.kARMQGor018386@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:30858 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S935563AbWK1FIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 00:08:11 -0500
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <200611272226.kARMQGor018386@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Nov 2006, Joy Latten wrote:

> This patch adds auditing to ipsec in 
> support of labeled ipsec. 
> An audit message occurs when an ipsec SA
> or ipsec policy is created/deleted.
> 
> Patch was built against linux kernel 2.6.19-rc6.
> Please let me know if this is acceptable. 

Looks ok to me.


Acked-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
