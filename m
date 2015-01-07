From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode callback
 function
Date: Wed, 7 Jan 2015 11:17:00 +0800
Message-ID: <20150107031658.GB4928@dragon>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
 <1419413441-3406-3-git-send-email-b38611@freescale.com>
 <20150106114807.GL24511@dragon>
 <BLUPR03MB373F1A5D01A8A6D16DC3364F5460@BLUPR03MB373.namprd03.prod.outlook.com>
 <20150107023307.GA4928@dragon>
 <BLUPR03MB37385464C06052A231ABF19F5460@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51365 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872AbbAGDRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:17:24 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so1915431pab.5
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 19:17:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BLUPR03MB37385464C06052A231ABF19F5460@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 02:40:33AM +0000, fugang.duan@freescale.com wrote:
> Yes, the platform code will become quite messy and tremendous.
> I agree with your thinking.
> 
> But David applied the patches, how can I do it now ?

David,

Can you please drop the last two arch/arm/ patches, or revert them if
your tree is non-rebasable?

Shawn
