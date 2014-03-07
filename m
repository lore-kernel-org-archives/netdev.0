From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 7 Mar 2014 12:07:27 +1100
Message-ID: <20140307120727.a4436ad2afc4b834db6b0641@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__7_Mar_2014_12_07_27_+1100_cL0D6DlT5Ejy393+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49017 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbaCGBHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 20:07:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__7_Mar_2014_12_07_27_+1100_cL0D6DlT5Ejy393+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/ath/ath9k/recv.c between commit 67ddc87f162e ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net") from the
net-next tree and commit f3b6a488a670 ("Merge branch 'master' of
git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless") from
the wireless-next tree.

I fixed it up (I used the version from the wireless-next tree) and can
carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__7_Mar_2014_12_07_27_+1100_cL0D6DlT5Ejy393+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTGRvTAAoJEMDTa8Ir7ZwVzR0QAIwZyZ65Jtk+rdkYEqU7XURH
VA8SDW9SE5GfZKFFaZQ1mcU6ii2R1GsbNLbeBp9FYwcKdy9zOLsCR1n7rhLNKPqV
e5ZfU7WyyRJrYaSRJ0dQBba3GQnWe7pLcUTFkQ3KEj9zMOPUGQLijkWoZxDRHEir
Xxuzr3ZJF78McmxD76+IpdOwq9nf8+cm01Jh2BxXL0YGBzRaeWNeZXSRWHtnnlgi
DwLFNr7W/h0zX2MMP4riymK2Kx0VniV9CUPZQsC9wIV2InhAlqRImdK9eSQHsqGD
bwL6Sqz3lveCq9EaoWl97ks25E9N3bZ21LSqs0hGC3uIFdrZdW4EgHhSib3Gr7B+
344aGjqWSaXC3u/QxGuTwv3nsw05P75M1UJvVu2l06W3cHEhWdB2g1387NVBZ45v
gvztO/gfVAuxiOL82OnRg0hB3xDrZ6e9WzACFX6KjNPkinZvxwYVboBGkOnvim58
zNdClG0MZKyibP4dCGTbYvMTWbGYqTX+8Su9hElbzRpQwBq1J1d+o5Zu7d+nKtav
dEpRCP3nmx31icR0Vkto72kUMm1pW6lUqye//Ue0cTlcGW9hGRMPrWcW7HZjGE3e
auPTeTF/Jt4D++i7CfYWi19deoJXOAswnpL/bNWk8zwkjps0/Rtv+Jp5c2eEtbe2
S1saqFOPinxLabxeM4Cs
=QyYm
-----END PGP SIGNATURE-----

--Signature=_Fri__7_Mar_2014_12_07_27_+1100_cL0D6DlT5Ejy393+--
