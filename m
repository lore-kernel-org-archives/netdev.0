From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 7/8] arm: convert omap ldp platform to use smsc911x
Date: Fri, 23 Jan 2009 17:07:12 +0000
Message-ID: <OF02435E0A.D8B49E71-ON80257547.005DE614-80257547.005E2CBE@smsc.com>
References: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: "Stanley.Miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4679 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760348AbZAWRJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2009 12:09:08 -0500
In-Reply-To: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Stanley.Miao" <stanley.miao@windriver.com> wrote on 21/01/2009 03:06:09:

> from 2.6.29, smc911x isn't maintained anymore. A new driver, smsc911x,
> will replace it. so convert omap_ldp to use smsc911x driver.
> 
> Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>

Hi Stanley,

This platform patch doesn't apply to linus's tree, what's it based on?

Thanks,
Steve
