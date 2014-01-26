From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: critic on documentation of the network stack
Date: Sun, 26 Jan 2014 22:33:19 +0100
Message-ID: <201401262233.20104.a.miskiewicz@gmail.com>
References: <20140124032324.GO7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:61550 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbaAZVdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 16:33:22 -0500
Received: by mail-ee0-f54.google.com with SMTP id e53so1897831eek.41
        for <netdev@vger.kernel.org>; Sun, 26 Jan 2014 13:33:21 -0800 (PST)
In-Reply-To: <20140124032324.GO7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 24 of January 2014, Hannes Frederic Sowa wrote:
> Hello!
>=20
> After net-next is closed I wanted to put the following link here:
>=20
>   <http://linux.slashdot.org/comments.pl?sid=3D4356053&cid=3D45184693=
>
>=20
> I don't want to start a flamefest or come too close to someone but I
> fear some of the critic is reasonable.  Maybe we can do better (I hav=
e
> to admit, I also hate writing documentation, e.g. have not yet send t=
he
> IP_PMTUDISC_INTERFACE man-page patches).
>=20
> I try to start with some constructive discussion:
>=20
> There are some great features in the network stack that some people m=
iss
> because of lack documentation. One possible solution is documentation
> directly in the kernel, but mostly this is just written as a referenc=
e
> and the real wonderful stuff is only achieved by putting lots of thos=
e
> features correclty together.
>=20
> Maybe this is the second or third time this was proposed but I'll try
> again: Would it make sense to just start slow and setup a wiki

Some other project never merge patches if there is no documentation.

Maintainers could do the same, so eg. kernel patch is merged only if th=
ere is=20
man-pages patch send, too (or other kind of documentation).

--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl
