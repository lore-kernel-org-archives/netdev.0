From: Vikram Narayanan <vikram186@gmail.com>
Subject: Re: i.Mx6Quad - eth0: tx queue full!
Date: Wed, 30 Jan 2013 20:48:27 +0530
Message-ID: <510939C3.1030505@gmail.com>
References: <5106B7EE.3040603@gmail.com> <5106D5D4.2090200@boundarydevices.com> <5107FA00.2010809@gmail.com> <51081910.4030707@boundarydevices.com> <9848F2DB572E5649BA045B288BE08FBE011B0826@039-SN2MPN1-022.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	Fabio Estevam <festevam@gmail.com>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:44021 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3A3PSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 10:18:40 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so1142564pac.29
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 07:18:40 -0800 (PST)
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE011B0826@039-SN2MPN1-022.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Duan,

On 1/30/2013 2:07 PM, Duan Fugang-B38611 wrote:
> Hi, all
>
> The issue cannot be found kernel 3.0.35 branch: (even run stress test with IPU and VPU)
> ssh://sw-git01-tx30/git/sw_git/repos/linux-2.6-imx.git

Where is this git located?

> branch name: imx_3.0.35

Troy's branch (located in github) works fine for me. I've kept it for a 
long run with heavy network load. Should I encounter some errors, I'll 
post back.

> The patch as below:
>
>  From 91a0c892263e57ecde9e9ff38be3acdb7f66a17f Mon Sep 17 00:00:00 2001
> From: Fugang Duan <B38611@freescale.com>
> Date: Thu, 9 Aug 2012 17:59:44 +0800
> Subject: [PATCH] ENGR00180288 - FEC : Fix kernel dump about eth0

Thanks, I'll give a try with this patch as well.

Regards,
Vikram
