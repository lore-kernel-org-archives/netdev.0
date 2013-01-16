From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [PATCH] sk-filter: Add ability to lock a socket filter program
Date: Wed, 16 Jan 2013 22:57:02 +0100
Message-ID: <m338y0eqq9.fsf@neo.luffy.cx>
References: <1358296955-30582-1-git-send-email-bernat@luffy.cx>
	<20130116.162012.1782638746075880444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:51455 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765Ab3APV5E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 16:57:04 -0500
In-Reply-To: <20130116.162012.1782638746075880444.davem@davemloft.net> (David
	Miller's message of "Wed, 16 Jan 2013 16:20:12 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 16 janvier 2013 22:20 CET, David Miller <davem@davemloft.net=
>=C2=A0:

>> +SO_LOCK_FILTER ioctl allows to lock the filter attached to a
>
> It's not an ioctl, it's a socket option.

I have sent an updated patch. I have also fixed the wording of other
options in the same file. I can do a separate patch if you think this i=
s
worth it.
--=20
Treat end of file conditions in a uniform manner.
            - The Elements of Programming Style (Kernighan & Plauger)
