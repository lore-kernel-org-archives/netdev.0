From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/4] IP100A: Fix TX Pause bug (reset_tx, intr_handler)
Date: Mon, 18 Sep 2006 19:03:45 +0200
Message-ID: <20060918170344.GA18364@electric-eye.fr.zoreil.com>
References: <20060915114448.GA7329@ingate.macqel.be> <005101c6dad4$47b1e2c0$4964a8c0@icplus.com.tw> <20060918094113.GA4873@ingate.macqel.be> <00b801c6db13$312b9840$4964a8c0@icplus.com.tw> <20060918130052.GA13012@ingate.macqel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Huang <jesse@icplus.com.tw>, netdev@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:4551 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751851AbWIRRFW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 13:05:22 -0400
To: Philippe De Muyter <phdm@macqel.be>
Content-Disposition: inline
In-Reply-To: <20060918130052.GA13012@ingate.macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe De Muyter <phdm@macqel.be> :
[...]
> On Mon, Sep 18, 2006 at 07:11:29PM +0800, Jesse Huang wrote:
> > Dear Philippe:
> > (1)Because this is a patent issue, we are not allow to use it again, even it
> > is in Data Sheet.
> 
> I surmise this is only a concern for icplus as a hardware company.

I'd rather avoid that any Linux user of the old sundance driver with
a new ip100a chipset instantly has some problem with the said patent.

Who would be responsible for it ? :o(

-- 
Ueimor
