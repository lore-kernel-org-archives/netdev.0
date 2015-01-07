From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode callback
 function
Date: Wed, 07 Jan 2015 07:02:53 -0500 (EST)
Message-ID: <20150107.070253.1720905189004397466.davem@davemloft.net>
References: <20150107023307.GA4928@dragon>
	<BLUPR03MB37385464C06052A231ABF19F5460@BLUPR03MB373.namprd03.prod.outlook.com>
	<20150107031658.GB4928@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbbAGMDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 07:03:44 -0500
In-Reply-To: <20150107031658.GB4928@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Wed, 7 Jan 2015 11:17:00 +0800

> On Wed, Jan 07, 2015 at 02:40:33AM +0000, fugang.duan@freescale.com wrote:
>> Yes, the platform code will become quite messy and tremendous.
>> I agree with your thinking.
>> 
>> But David applied the patches, how can I do it now ?
> 
> David,
> 
> Can you please drop the last two arch/arm/ patches, or revert them if
> your tree is non-rebasable?

My tree is non-rebasable, someone will need to send me a revert patch
which has a commit message explains why the revert is happening.
