From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Mon, 9 Jan 2017 09:51:04 +0200
Message-ID: <20170109075104.GV15685@mtr-leonro.local>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GPT5DIEyVHz5yXBV"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com
To: Doug Ledford <dledford@redhat.com>,
        "ira.weiny" <ira.weiny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:36742 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750718AbdAIHvB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 02:51:01 -0500
Content-Disposition: inline
In-Reply-To: <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GPT5DIEyVHz5yXBV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:
> On 12/15/2016 9:52 AM, ira.weiny wrote:
>
> 2) With more than 60% of the code being MAD related, and another
> significant chunk being hfi related, and only a minor bit (20% maybe?)
> being net related,

Hi Doug and Ira,

I may admit that I didn't read the code very deep, but from brief
overview, I didn't find support for the claim the "60% code is MAD related".
It looks like the opposite thing will be more accurate.

Can you help me to understand this claim? How did you come to this
conclusion?

Thanks

--GPT5DIEyVHz5yXBV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhzQOgACgkQ5GN7iDZy
WKdYwQ//QMRH+k9PhmFeH98e/De69+UbulxhMg6J6JmvJc9UNK8dPxtrYdpPh2Ba
n/RmVZNcoK7rPknCe6VKmMrlcKrSZPZrifqjpP0fCiF+jNvJ5KoMPBYOVagN9/xa
Hm3oaH7p5b24l+pk6KdzNErB6BS+f5O+4pLxxH1yIfh/7n2GTdm6rauJx+Udao6A
QKhqX6QIRhdGgimDdsDLRYg9xS7tJwacVT7jzbhR7FuA8MLcMSjGxPAfnYGFX/YH
85cGJXNUh+k0xzdRvHmnx4jl37+Y+mh6n9yd7f+4tp8PS3+R4d8Oh4njA5ZmEcTE
dyenyUV2PZG41ZfDskShjmVrTNPmXLH+pjQY/LxIP08+AHbepXGUwEPQMf7h8/cC
vMbTPnUiHPR+hgSRE+vtmL795jYBdRz1539i97T5k49oVsaFZZgl76nQ5nd4yf3Q
ALRTihPNGsSbQuBjBEzW1aMuh1evsqIvzSrpz/i5w7vbammyhnwP4cc3L9jGBugp
kc5H+gsdhmQD4ut6lNq9FsXRZP+dob1BCD2PsV7l6S1PPaAO8cRrud2qjzijc2js
olFxPoH/tMfZ/2As9FKPFJN0D8+BczpjkB9euRc+iqDcLi2vph8PsU8mxev+DqXU
RsF4cdBmjePhRTZ1JF8/5H/O+yl7i8xyiCdHrVuy0uTJs1/lIXg=
=SlX4
-----END PGP SIGNATURE-----

--GPT5DIEyVHz5yXBV--
