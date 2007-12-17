From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Packet per Second
Date: Mon, 17 Dec 2007 14:22:55 +0200
Message-ID: <20071217122255.GK6372@mea-ext.zmailer.org>
References: <nemoFri121407105527@flis.man.torun.pl> <1197671513.5973.10.camel@andromache> <nemoMon121707091528@flis.man.torun.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?Fl=E1vio?= Pires <flavio.defreitas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:38177 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935390AbXLQMW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 07:22:57 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540007AbXLQMWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 14:22:55 +0200
Content-Disposition: inline
In-Reply-To: <nemoMon121707091528@flis.man.torun.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 11:18:57AM +0000, Fl=E1vio Pires wrote:
> In article <1197671513.5973.10.camel@andromache> Glen
> Turner<gdt@gdt.id.au> wrote:
> >  On Fri, 2007-12-14 at 15:34 +0000, Fl=87vio Pires wrote:
> >>   Well, I work on an ISP and we have a linux box acting as a
> >> bridge+firewall. With this bridge+firewall we control the packet
> >> rate per second from each client and from our repeaters. But I can=
`t
> >> measure the packet rate per IP. Is there any tool for this?
>=20
> Thx for the answer Glen,
>=20
> I alread though about something like this. But, isn`t NetFlow just fo=
r
> Cisco IOS ?

You probably want this, or at least its sources:

   http://packages.debian.org/stable/net/fprobe-ng


the "non-ng" version is probably called:   fprobe-ulog

Then you want also NetFlow collector/accounter..

/Matti Aarnio
