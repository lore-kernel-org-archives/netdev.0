From: =?ISO-8859-1?Q?S=F8ren?= Holm <sgh@sgh.dk>
Subject: Re: [PATCH] asix: Support DLink DUB-E100 H/W Ver C1
Date: Tue, 18 Sep 2012 09:49:02 +0200
Message-ID: <1377162.WNQkapDPaD@koontz>
References: <1347909800-3056-1-git-send-email-sgh@sgh.dk> <CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe.ge-0-2-0-950.faaqnqu1.customer.tele.dk ([93.167.193.18]:59235
	"EHLO mail.mikrofyn.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755390Ab2IRIDV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:03:21 -0400
In-Reply-To: <CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tirsdag den 18. september 2012 07:41:11 skrev Christian Riesch:
>=20
> This will not apply to recent kernels, drivers/net/usb/asix.c has bee=
n
> split into several files, please make these changes in
> drivers/net/usb/asix_devices.c.

I'll do that. The previous patch applies to the 3.5.x stable series if =
it get=20
accepted there.

Thanks for the feedback.

--=20
S=F8ren Holm
