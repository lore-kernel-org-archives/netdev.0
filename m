From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 20:57:56 +0800
Message-ID: <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
 <b2c34db84e88366e465af590900ae3db@localhost> <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
 <1290153111.29509.2.camel@edumazet-laptop> <1290153398.29509.7.camel@edumazet-laptop>
 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
 <1290160467.3034.33.camel@edumazet-laptop> <1290165472.3034.109.camel@edumazet-laptop>
 <AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39397 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab0KSM6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 07:58:18 -0500
Received: by fxm13 with SMTP id 13so621205fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 04:58:17 -0800 (PST)
In-Reply-To: <AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 8:32 PM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> you missed the users of sk_run_filter in directory dev/.
>

Sorry, the directory is drivers/.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
