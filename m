From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] Packet per Second
Date: Fri, 14 Dec 2007 08:56:02 -0800
Message-ID: <20071214085602.11a09070@deepthought>
References: <nemoFri121407105527@flis.man.torun.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: =?UTF-8?B?RmzDoXZpbw==?= Pires <flavio.defreitas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49642 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbXLNQ5b convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 11:57:31 -0500
In-Reply-To: <nemoFri121407105527@flis.man.torun.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 15:34:10 +0000 (UTC)
=46l=C3=A1vio Pires <flavio.defreitas@gmail.com> wrote:

> Hi all,=20
>=20
> It's my first time using usenet...
>=20
> Well, I work on an ISP and we have a linux box acting as a
> bridge+firewall. With this bridge+firewall we control the packet rate
> per second from each client and from our repeaters. But I can`t
> measure the packet rate per IP. Is there any tool for this?
>=20
> Actually, what I want is to measure the packet rate per IP and
> generate graphics with mrtg or rrdtool, but for this I must have the
> number of packets per second of each client :)
>=20
> Thank you all
> --
> Fl=C3=A1vio
>=20
>=20


Not that I know of, but you might look at:
http://www.bandwidtharbitrator.com/
--=20
Stephen Hemminger <shemminger@linux-foundation.org>
