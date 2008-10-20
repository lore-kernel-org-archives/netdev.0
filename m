From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Mon, 20 Oct 2008 19:15:30 +0200
Message-ID: <20081020171530.GA2564@ami.dom.local>
References: <bug-11721-11547@http.bugzilla.kernel.org/> <20081020154737.2D0CA108042@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: =?us-ascii?B?PT9JU08tODg1OS0xP1E/SWxwb19KPUU0cnZpbmVuPz0=?=
	<ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:39893 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889AbYJTRP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 13:15:26 -0400
Received: by nf-out-0910.google.com with SMTP id d3so966112nfc.21
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 10:15:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810201256120.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2008 at 08:47:37AM -0700, bugme-daemon@bugzilla.kernel.=
org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=3D11721
=2E..
> ------- Comment #40 from sentiniate@tiscali.it  2008-10-20 08:47 ----=
---
> ok setting echo 0 > /proc/sys/net/ipv4/tcp_timestamps solves the prob=
lem as
> well.
>=20
> anyway i'm willing to do whatever test you deem necessary if this can=
 help you
> solve the issue, so as soon as i can i'll apply the patch provided by=
  Ilpo
> J=E4rvinen and compile (do not worry i've been a linux user for the l=
ast 10
> years and up to 4 or 5 yrs ago i used to compile even three times a w=
eek!)
>=20
> thanks
> aldo

Aldo, I forward this message to Ilpo and netdev, because "they" aren't
on the Cc list of this report. (With next replies try to use the mail
with their addresses.)

I think, you could test Ilpo's patch as well: this would make slightly
different test/header. (Of course, all these /proc tcp values and mtus
should be back to normal.)

Thanks,
Jarek P.
