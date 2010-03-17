From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 09:54:19 +0800
Message-ID: <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	<20100316.141311.262178287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:50249 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab0CQByk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 21:54:40 -0400
Received: by iwn6 with SMTP id 6so483271iwn.4
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 18:54:39 -0700 (PDT)
In-Reply-To: <20100316.141311.262178287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 5:13 AM, David Miller <davem@davemloft.net> wro=
te:
>
> I'll integrate this as soon as I open up net-next-2.6

It is really a good news. Now linux also can dispatch packets as
=46reeBSD does via netisr. Can we walk farer, and support weighted
distribution?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
