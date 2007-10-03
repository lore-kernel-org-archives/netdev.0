From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v4] qe: miscellaneous code improvements and fixes to the QE library
Date: Wed, 3 Oct 2007 17:41:58 -0500
Message-ID: <B596192A-5A72-463A-A927-312FC6FA35DA@kernel.crashing.org>
References: <1191429299378-git-send-email-timur@freescale.com> <20071003094449.702c4a90@freepuppy.rosehill> <4703D8B9.5080006@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53708 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbXJCWmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 18:42:05 -0400
In-Reply-To: <4703D8B9.5080006@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 3, 2007, at 1:00 PM, Timur Tabi wrote:

> Stephen Hemminger wrote:
>
>> Separate the changes into individual patches to allow for better  
>> comment/review
>> and bisection in case of regression.
>
> That would be too difficult.  Some of the changes are single lines,  
> and this patch has already been approved -- I just cross-posted to  
> netdev because I made a few ucc_geth changes that can't be  
> docoupled from the powerpc changes.  A series of 18 patches would  
> just be convoluted.

Normally I would agree, but at this point I'm not going to gripe too  
much about it.

- k
