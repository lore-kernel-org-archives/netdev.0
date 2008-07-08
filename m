From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 06/12] net: use linux/of_{device,platform}.h instead of asm
Date: Tue, 8 Jul 2008 08:28:49 -0500
Message-ID: <272CD580-72C6-4671-8588-8385A4C2300F@kernel.crashing.org>
References: <20080523161627.a75d5010.sfr@canb.auug.org.au> <20080523162854.2e6ea8f0.sfr@canb.auug.org.au> <4864737D.80306@garzik.org> <C87095E8-991D-4730-8C5A-B132A3157727@kernel.crashing.org> <20080703112835.c082177b.sfr@canb.auug.org.au>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ppc-dev <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47327 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbYGHN3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 09:29:08 -0400
In-Reply-To: <20080703112835.c082177b.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 2, 2008, at 8:28 PM, Stephen Rothwell wrote:

> Hi Kumar,
>
> On Wed, 2 Jul 2008 02:55:29 -0500 Kumar Gala <galak@kernel.crashing.org 
> > wrote:
>>
>> I'll pick it up (since it mainly touches fsl enet controllers) if you
>> can repost it.  I seem to have lost the patch.
>
> Here you go.
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> http://www.canb.auug.org.au/~sfr/

Thanks, there have been a number of changes so this doesn't apply  
anymore.  I'd suggest we hold on to it for a little while and let the  
driver churn calm down first.

- k
