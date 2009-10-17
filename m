From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sat, 17 Oct 2009 19:04:52 -0400
Message-ID: <1255820692.4815.2.camel@dogo.mojatatu.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
	 <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
	 <1255782635.11213.7.camel@dogo.mojatatu.com>
	 <55a4f86e0910171154v460146a8m1360fac71f9ddac8@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rob.Townley@gmail.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:39737 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403AbZJQXHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 19:07:53 -0400
Received: by qyk32 with SMTP id 32so2215838qyk.4
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2009 16:07:58 -0700 (PDT)
In-Reply-To: <55a4f86e0910171154v460146a8m1360fac71f9ddac8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-10-17 at 11:54 -0700, Maciej =C5=BBenczykowski wrote:
> This patch requires the currently being suggested/reviewed/written
> 'fix SO_MARK' patches, some of which have already been committed.
>=20

Elucidate please.

SO_MARK has been in for at least a year. This patch has worked fine in
2.6.31 and pre-31 where i tested. What patches and what are they fixing
in this regard to get this working?

cheers,
jamal

