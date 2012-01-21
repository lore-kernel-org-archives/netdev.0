From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH 1/1] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Sun, 22 Jan 2012 00:47:47 +0530
Message-ID: <CA+Dx6Hbbe0OadeyNQtO1__dU3K5VSecHajFQPSJiD=GSci+Nqw@mail.gmail.com>
References: <1327156996-12505-1-git-send-email-netdev@pradeepdalvi.com>
	<1327161238.2574.3.camel@edumazet-laptop>
	<CA+Dx6HbdHV9qHksqb0oH-zhYdJCm6Tu8btwG1Zs5ty1CPXXckA@mail.gmail.com>
	<20120121.133933.227768598621914035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hch@lst.de,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34995 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750940Ab2AUTRt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jan 2012 14:17:49 -0500
In-Reply-To: <20120121.133933.227768598621914035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2012 at 12:09 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
> Date: Sat, 21 Jan 2012 22:16:06 +0530
>
>> I appreciate your concerns. Although I feel, it is essential to add
>> relevant comments by respective (corporate/paid :-) developers, if
>> their hardware needs hardcoded 2. And especially, if their expectati=
on
>> is to buy their hardware, even for the smaller purpose of having
>> uniform mechanism. Long live Open Source! :-)
>
> I see the smiley but it is your responsibility to learn how a driver
> works before making changes to it that break them. =A0Stop talking su=
ch
> foolishness, it is very unbecoming of a serious developer.

Certainly! I completely agree to the point of being responsible
contributor and in another words, not to break existing things due to
lack of information.
Although I mentioned so, due to realized importance of
comments/documentation over the expectations of owning hardware for
testing. Especially, if those points are so much critical to the
hardware. And also more importantly, while accessing Kernel resources.
Anyways, I would avoid touching +2 further, like I've avoided for +3,
+4, +5 and so on, in this patch & resubmit the patch. Thanks!
