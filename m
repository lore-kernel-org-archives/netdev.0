From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: reimplement softnet_data.output_queue as a
 FIFO  queue
Date: Mon, 26 Apr 2010 11:30:59 +0200
Message-ID: <1272274259.2346.23.camel@edumazet-laptop>
References: <1272252361-11799-1-git-send-email-xiaosuo@gmail.com>
	 <q2p412e6f7f1004260211t19efd3ebk183577ac4a39d31e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:55108 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010Ab0DZJbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 05:31:06 -0400
Received: by bwz19 with SMTP id 19so2132bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 02:31:03 -0700 (PDT)
In-Reply-To: <q2p412e6f7f1004260211t19efd3ebk183577ac4a39d31e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 17:11 +0800, Changli Gao a =C3=A9crit :
> On Mon, Apr 26, 2010 at 11:26 AM, Changli Gao <xiaosuo@gmail.com> wro=
te:
> > reimplement softnet_data.output_queue as a FIFO queue.
> >
> > reimplement softnet_data.output_queue as a FIFO queue to keep the f=
airness among
> > the qdiscs rescheduled.
> >
>=20
> Dear Eric:
>   do you think it is worth continuing? I didn't received any comments
> even negative ones. I am really sorry for disrupting you, but I don't
> know what did it mean.
>=20

=46or this patch I had no comment, I believe it is fine, at a first
glance...

Please give some time for netdev people to review it and Ack it.



