From: Patrick McHardy <kaber@trash.net>
Subject: Re: AW: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 13:54:11 +0100
Message-ID: <474C1373.6080308@trash.net>
References: <773358.67616.qm@web51408.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58038 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbXK0MyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 07:54:19 -0500
In-Reply-To: <773358.67616.qm@web51408.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Pommnitz wrote:
>  > It works fine here, I'm guessing that J=F6rg is using an old kerne=
l
>  > version that had a bug in prio classification without filters.
>=20
> This is 2.6.20.21, from 17-Oct-2007.=20


Yes, that version is broken. I think it was fixed in 2.6.22 or 2.6.23.
