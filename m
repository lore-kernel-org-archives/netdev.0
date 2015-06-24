From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: merge window freeze
Date: Wed, 24 Jun 2015 13:25:47 +0300
Message-ID: <EC3F09A3-8B3D-4ABD-B94D-1A36D13DF09A@cumulusnetworks.com>
References: <20150624.025328.682044271321726878.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:38313 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbbFXKZv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 06:25:51 -0400
Received: by wibdq8 with SMTP id dq8so42023934wib.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 03:25:50 -0700 (PDT)
In-Reply-To: <20150624.025328.682044271321726878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 24, 2015, at 12:53 PM, David Miller <davem@davemloft.net> wrot=
e:
>=20
>=20
> I've processed all of my patch backlog and plan to do some merging
> then prepare a pull request of net-next for Linus.
>=20
> DO NOT submit any net-next changes at this time, please instead
> wait for net-next to open up again (should be some time next week
> or so).
>=20
> Bug fixes, of course, are always welcome.
>=20
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Dave,
I noticed that both of my bridge patches are marked with =E2=80=9CChang=
es Requested=E2=80=9D, but
there was no feedback why and also the first one:
"bridge: multicast: add a comment to br_port_state_selection about bloc=
king state=E2=80=9D
was ACKed and in the second one our discussion with Toshiaki
was about a possible bug that=E2=80=99s not related to the patch.=20
Could you please tell me what I have to change in them ?

Patch links:
[1] https://patchwork.ozlabs.org/patch/487591/
[2] https://patchwork.ozlabs.org/patch/487608/

Thank you,
 Nik
