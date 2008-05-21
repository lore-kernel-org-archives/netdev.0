From: Alan Swanson <swanson@ukfsn.org>
Subject: Re: IPSEC IPV4 Tunnel Requires IPV6 WIth 2.6.25?
Date: Wed, 21 May 2008 21:18:16 +0100
Message-ID: <1211401096.3631.14.camel@zeus.local>
References: <1210882182.9684.27.camel@zeus.local>
	 <48340F01.6050104@miyazawa.org>  <483412C0.2060404@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:34764 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S936779AbYEUUSY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 16:18:24 -0400
In-Reply-To: <483412C0.2060404@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-05-21 at 21:17 +0900, Kazunori MIYAZAWA wrote:
> Kazunori MIYAZAWA =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=81=
=BE=E3=81=97=E3=81=9F:
> > Hello,
> >=20
> > This patch fixes the problem.
> > I though that someone (sorry I foget) sent the same patch
> > when netlink was fixed.
> >=20
>=20
> Sorry I did typo.

Hi Kazunori.

Confirmed, that patch fixed the problem. =EF=BB=BFThanks very much.

I don't see if this single line regression from the "inter address
family IPsec tunnel on the fly" patch has reverted in any Git trees yet=
=2E
A candidate for stable perhaps?

--=20
Alan.

"One must never be purposelessnessnesslessness."
