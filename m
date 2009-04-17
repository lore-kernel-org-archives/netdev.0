From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Kconfig net device compat fixup
Date: Fri, 17 Apr 2009 10:33:17 +0200
Message-ID: <20090417103317.568f5e85@hskinnemoen-d830>
References: <1239953045.2837.58.camel@linux-51e8.site>
	<20090417094602.51ec1b21@hskinnemoen-d830>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Ferre, Nicolas" <Nicolas.FERRE@atmel.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Ben Nizette <bn@niasdigital.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:51902 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753831AbZDQIdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 04:33:44 -0400
In-Reply-To: <20090417094602.51ec1b21@hskinnemoen-d830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Haavard Skinnemoen wrote:
> > Of course really macb should be updated but in the mean time, this at
> > least avoid randconfig problems.  
> 
> It doesn't look all that difficult. Could you try the below instead?

Better yet, try this one:

http://patchwork.ozlabs.org/patch/25861/

which is the one that has been applied to -next.

Haavard
