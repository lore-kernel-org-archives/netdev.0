From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Wed, 11 Nov 2009 12:35:37 -0500
Message-ID: <4AFAF5E9.1040906@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <4AF978D3.7030207@gmail.com> <4AF98AAE.6000307@gmail.com> <alpine.DEB.2.00.0911110235270.2864@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:45111 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758380AbZKKRfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 12:35:39 -0500
Received: by fxm21 with SMTP id 21so1267279fxm.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 09:35:44 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911110235270.2864@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Tue, 10 Nov 2009, William Allen Simpson wrote:
>> Well, that's what I did with the (now) parts 1b, 1c, and 1d, but som=
ebody
>> complained that the callers didn't exist yet.
>=20
> I guess there's misunderstanding here. Yes, if you bring in new helpe=
rs=20
> that solely are used with your feature, then it that feature patch (a=
nd=20
> I found DaveM commenting specifically this point I think), or right=20
> beforehand with a clear note that it will be used in the subsequent p=
atch.=20

If I understand correctly, in that case I look forward to your Ack for
part 1d, a self-contained "helper" feature patch "with a clear note".
