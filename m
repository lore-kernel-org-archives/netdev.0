From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 15:27:32 +0100
Message-ID: <1298039252.6201.66.camel@edumazet-laptop>
References: <20110218132524.GC2939@psychotron.redhat.com>
	 <1298035791.6201.56.camel@edumazet-laptop>
	 <20110218141456.GD2939@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36652 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757686Ab1BRO1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 09:27:50 -0500
Received: by fxm20 with SMTP id 20so3832665fxm.19
        for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 06:27:49 -0800 (PST)
In-Reply-To: <20110218141456.GD2939@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 15:14 +0100, Jiri Pirko a =C3=A9=
crit :

> Do not know how to do it better. As for percpu variable, not only
> origdev would have to be remembered but also probably skb pointer to
> know if it's the first run on the skb or not. Can't really figure out=
 a
> better solution. Can you?

I'll try and let you know.

Thanks


