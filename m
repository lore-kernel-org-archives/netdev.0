From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] vlan: Don't allow vlan devices to change network
 namespaces.
Date: Tue, 22 Apr 2014 14:54:32 +0200
Message-ID: <53566688.3060008@6wind.com>
References: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>, kaber@trash.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:60214 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaDVMyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 08:54:37 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so4998553wes.28
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 05:54:35 -0700 (PDT)
In-Reply-To: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/04/2014 14:43, Chen Weilong a =C3=A9crit :
> From: Weilong Chen <chenweilong@huawei.com>
>
> Like bonding, vlan as netdevice doesn't cross netns boundaries.
>
> Vlan port and vlan itself live in same netns.
>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Do you propose this patch because you've seen bugs?
I think that it's interesting to have this x-netns feature.


Regards,
Nicolas
