From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH 7/8] arm: convert omap ldp platform to use smsc911x
Date: Sat, 24 Jan 2009 12:16:32 +0800
Message-ID: <1232770592.18235.3.camel@localhost>
References: <OF02435E0A.D8B49E71-ON80257547.005DE614-80257547.005E2CBE@smsc.com>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48795 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321AbZAXEHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2009 23:07:38 -0500
In-Reply-To: <OF02435E0A.D8B49E71-ON80257547.005DE614-80257547.005E2CBE@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-23 at 17:07 +0000, Steve.Glendinning@smsc.com wrote:
> "Stanley.Miao" <stanley.miao@windriver.com> wrote on 21/01/2009 03:06:09:
> 
> > from 2.6.29, smc911x isn't maintained anymore. A new driver, smsc911x,
> > will replace it. so convert omap_ldp to use smsc911x driver.
> > 
> > Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
> 
> Hi Stanley,
> 
> This platform patch doesn't apply to linus's tree, what's it based on?

Sorry, I reworked it to base on linus's tree.

Stanley.

> 
> Thanks,
> Steve
