From: David Lv <davidlv.linux@gmail.com>
Subject: Re: [PATCH] via-velocity: fix the WOL bug on 1000M full duplex forced mode.
Date: Wed, 23 Mar 2011 18:07:54 +0800
Message-ID: <AANLkTikoVgwu1SQ_fpTLS3coqOWbMy__9Y9eANYYmkWo@mail.gmail.com>
References: <20110120145933.GC7291@electric-eye.fr.zoreil.com>
	<20110120.165634.257520752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	DavidLv@viatech.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49226 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401Ab1CWKL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 06:11:57 -0400
Received: by fxm17 with SMTP id 17so7181498fxm.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 03:11:56 -0700 (PDT)
In-Reply-To: <20110120.165634.257520752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David. I haven't found out this patch code in the mainline of 2.6.3=
8.
Could you help me check it?
Thanks!


Best regards



2011/1/21 David Miller <davem@davemloft.net>:
> From: Francois Romieu <romieu@fr.zoreil.com>
> Date: Thu, 20 Jan 2011 15:59:33 +0100
>
>> The VIA velocity card can't be waken up by WOL tool on 1000M full
>> duplex forced mode. This patch fixes the bug.
>>
>> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
>> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
>
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
