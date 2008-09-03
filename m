From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: + e1000e-prevent-corruption-of-eeprom-nvm.patch added to -mmtree
Date: Wed, 3 Sep 2008 21:04:47 +0400
Message-ID: <200809032104.49092.arvidjaar@mail.ru>
References: <200809021919.m82JJweC008488@imap1.linux-foundation.org> <36D9DB17C6DE9E40B059440DB8D95F5206051BF7@orsmsx418.amr.corp.intel.com> <1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2710223.Fvsj6mRO1v";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Qicheng Christopher Li <chrisl@vmware.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx28.mail.ru ([194.67.23.67]:23351 "EHLO mx28.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbYICSEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 14:04:08 -0400
Received: from mx27.mail.ru (mx27.mail.ru [194.67.23.23])
	by mx28.mail.ru (mPOP.Fallback_MX) with ESMTP id 595AF772C03
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2008 21:06:55 +0400 (MSD)
In-Reply-To: <1220429845.32688.182.camel@bodhitayantram.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2710223.Fvsj6mRO1v
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 03 September 2008, Zachary Amsden wrote:
> I'm sorry, we have no way to reproduce this, don't know anything about
> the hardware the customer was using

According to my information bug affects LAN controllers based on Intel 8254x GBe chipset. Of course, I do not claim it is exhaustive list.

--nextPart2710223.Fvsj6mRO1v
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAki+w7EACgkQR6LMutpd94y2lwCgi2+USmMWIeaJsivK+gVrB3xP
jKYAn0XlISjI5UuCi7aFvTP6a0OVBtWX
=NVvA
-----END PGP SIGNATURE-----

--nextPart2710223.Fvsj6mRO1v--
