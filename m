From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] fix WOL on 2nd port on i350
Date: Wed, 6 Jul 2011 01:53:01 -0700
Message-ID: <CAL3LdT4VYOVXm26J4UhWo-4z_1ckkDzt_CsieyU5tGs22pbjHw@mail.gmail.com>
References: <4E11CB87.5040806@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	"Uhe, Rudolf" <rudolf.uhe@ts.fujitsu.com>
To: Martin Wilck <martin.wilck@ts.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:46031 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab1GFIxC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 04:53:02 -0400
Received: by fxd18 with SMTP id 18so6993154fxd.11
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 01:53:01 -0700 (PDT)
In-Reply-To: <4E11CB87.5040806@ts.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2011 at 07:17, Martin Wilck <martin.wilck@ts.fujitsu.com=
> wrote:
> WOL fails on second port of a i350 network adapter with the latest
> upstream kernel driver. It works with the sf.net driver 3.0.19. The
> following patch seems to be missing upstream.
>
> Regards,
> Martin
>
> --
> Dr. Martin Wilck
> PRIMERGY System Software Engineer
> x86 Server Engineering
>
> FUJITSU
> Fujitsu Technology Solutions GmbH
> Heinz-Nixdorf-Ring 1
> 33106 Paderborn, Germany
> Phone: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
++49 5251 525 2796
> Fax: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0++49 5251 525 2820
> Email: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
martin.wilck@ts.fujitsu.com
> Internet: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 http://ts.=
fujitsu.com
> Company Details: =C2=A0 =C2=A0 =C2=A0 =C2=A0http://ts.fujitsu.com/imp=
rint
>
>

Thanks, we should have a patch to sync up the upstream driver in
net-next (3.1) here soon.

--=20
Cheers,
Jeff
