From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] LSM-IPsec SELinux Authorize (with minor fix)
Date: Thu, 08 Jun 2006 23:40:03 -0700 (PDT)
Message-ID: <20060608.234003.18579552.davem@davemloft.net>
References: <Pine.LNX.4.64.0606060133220.9787@d.namei>
	<OF4F545512.79E4862D-ON85257185.005181A7-85257185.00520729@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, latten@austin.ibm.com, sergeh@us.ibm.com,
	gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29862
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965232AbWFIGkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 02:40:49 -0400
To: cxzhang@us.ibm.com
In-Reply-To: <OF4F545512.79E4862D-ON85257185.005181A7-85257185.00520729@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaolan Zhang <cxzhang@us.ibm.com>
Date: Tue, 6 Jun 2006 10:55:58 -0400

> Singned-off-by: Catherine Zhang <cxzhang@watson.ibm.com>
> 
> James, is this enough or do I need to modify the original patch to add the 
> above line?  The code was taken from various pieces of patches originally 
> from Trent and merged/modified by me.  Let me know what else I need to do.

That's good enough for me, patch applied, thanks a lot.
