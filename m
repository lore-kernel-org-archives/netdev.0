From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messages
 using PF_KEY
Date: Fri, 14 Jul 2006 09:54:59 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607140952220.15305@d.namei>
References: <44B56642.6060500@trustedcs.com> <20060713.230445.106436593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vyekkirala@trustedcs.com, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:54949 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030450AbWGNNzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 09:55:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060713.230445.106436593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jul 2006, David Miller wrote:

> The other changes I'm either OK with, or they are outside my scope of
> knowledge (the stuff that lives inside of SELINUX).

The security side of things looks ok to me.

Herbert, any review from you on this would be greatly appreciated.


- James
-- 
James Morris
<jmorris@namei.org>
