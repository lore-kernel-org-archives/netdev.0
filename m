From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: Re: fake rtable dst patch applied but kernel keeps panicing
Date: Thu, 19 Apr 2012 16:22:43 +0800
Message-ID: <4F8FCB53.7070603@huawei.com>
References: <4F8E9291.9000607@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([58.251.152.66]:38948 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab2DSIXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:23:17 -0400
Received: from huawei.com (szxga03-in [172.24.2.9])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M2P00JNHWM0CG@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Thu, 19 Apr 2012 16:22:48 +0800 (CST)
Received: from szxrg02-dlp.huawei.com ([172.24.2.119])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M2P00EL0WM0F8@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Thu, 19 Apr 2012 16:22:48 +0800 (CST)
In-reply-to: <4F8E9291.9000607@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Massimo

can this be reproduce easily or depend on some HW or SW environment?

This patch already verified on 2.6.32.36/54,3.3.1, 3.4.rc[23] for over
6 hours, but didn't encounter this problem.

On 2012/4/18 18:08, Massimo Cetra wrote:
> Hi Eric,
> Hi Peter,
>
> I applied the 1st patch by Peter to a 3.2.14 kernel, compiled, installed
> and rebooted.
>
> I have had another panic and i'm attaching the oops as i received it
> through netcnsole.
>
> I don't think the patch is enough to prevent the OOPS.
>
> Can i be helpful in some way ?
>
> Thanks,
> Massimo
