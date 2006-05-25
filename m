From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 14:59:00 -0700 (PDT)
Message-ID: <20060525.145900.21925817.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F150CE2B@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, ZHOU0022@ntu.edu.sg, baruch@ev-en.org,
	jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19647
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030463AbWEYV6z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 17:58:55 -0400
To: caitlinb@broadcom.com
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F150CE2B@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Caitlin Bestler" <caitlinb@broadcom.com>
Date: Thu, 25 May 2006 14:11:03 -0700

> The *desirability* of using this data is debatable, but it most
> certainly is possible.

Right, I don't think these kinds of schemes scale very well
personally.

I think TCP can certainly infer these attributes using
existing information.  With %100 precision, no of course
not, but definitely a good enough approximation for real
use.
