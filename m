From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: cleanup codes[] init
Date: Fri, 19 Nov 2010 20:21:57 +0800
Message-ID: <AANLkTi=GLX-biB0ApDFMD2GOYyqb2qghMSHScmBTJv-O@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
 <b2c34db84e88366e465af590900ae3db@localhost> <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
 <1290153111.29509.2.camel@edumazet-laptop> <1290153398.29509.7.camel@edumazet-laptop>
 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com> <1290160467.3034.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55700 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab0KSM1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 07:27:07 -0500
Received: by fxm13 with SMTP id 13so597877fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 04:27:06 -0800 (PST)
In-Reply-To: <1290160467.3034.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 5:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Most probably you have "CONFIG_CC_OPTIMIZE_FOR_SIZE=y" which
> unfortunately is known to generate poor looking code.

Yes. So

Acked-by: Changli Gao <xiaosuo@gmail.com>


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
