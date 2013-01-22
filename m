From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: 69b08f62 breaks ethernet on atl1c based Eee PC 1011px
Date: Tue, 22 Jan 2013 16:25:16 +0100
Message-ID: <20130122162516.0f7410ba@milhouse>
References: <20130121222926.392f1244@milhouse>
	<CANn89iK6kuLeg1TCobdHMKK5dYZuP0mRSb25v9C4pdP2F7MrLA@mail.gmail.com>
	<20130122133123.57085db8@milhouse>
	<CANn89iK5iEL5HnGxtRR2Gk_EEcV5wUmiAB9XgNwn9c-+c2M5gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/HhN7UHX_T1r8FPW7F3TK6zy"; protocol="application/pgp-signature"
Cc: linux-netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:55808 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238Ab3AVPZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 10:25:39 -0500
In-Reply-To: <CANn89iK5iEL5HnGxtRR2Gk_EEcV5wUmiAB9XgNwn9c-+c2M5gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/HhN7UHX_T1r8FPW7F3TK6zy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Jan 2013 07:16:49 -0800
Eric Dumazet <edumazet@google.com> wrote:

> Its probably a VM issue fixed by Mel Gorman in
> commit 8fb74b9fb2b182d54beee592350d9ea1f325917a
>=20
> mm: compaction: partially revert capture of suitable high-order page

That was already applied in 3.7.3 as e5e65a5233c3f368c442413cebe7de2a4580b5=
64,
so it doesn't fix the issue.

--=20
Greetings, Michael.

PGP: 908D8B0E

--Sig_/HhN7UHX_T1r8FPW7F3TK6zy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ/q9cAAoJEPUyvh2QjYsOfCQP/013tYbrwsrhc8Dk6gfoVcHL
c/rNg+pO9D/h0o8GA1pYfaEIEr3hh9NyjL0f0y9CPRVnw44WlWEvFFok88eClig8
mtrzMb0Hyiicaac6hzrgDbNu82BE76+xxYV+aTa1MNmybpyruqvhFxzRw1K90uvu
6zSfpHAEvp2C/Jtrr11VpMRW1FPYC9YPYI2GrUs7Y+BkXNbfq56M5LSLr1jQiH5r
4/GVSz5DK2143IvDeH3sTfA5Syyym8l4uk6nUMnGT9IUlxBGJ+oVGgi7fes6e8T6
J9Lrs6QTQ+UftzmONGm6dlF67iAT7SJt0ZhNIbQe/XO/DlTWWuBiEDAcu2oqvYfv
FGB2APxDYqyp/TrnZc3nQvDPzS2zQwOqNP23/ZaU+B166+u64I0q5F4hFoqfrD4x
tVgLYsrOKiVUuhgXsr2v1WqUk8aLnKEo/bORti4x1v8x3l7+5CDZfrZ1z91gEe26
+gazv1vo1H6TrOnUnvbaGbzWtq7WfxvpM0HVHLF23tSZ14Nty8bjdbsjif21YZTB
q16bF5AOOo5aYrqtrM94BSD98kkXEFQkn2mGaqRmLsC3Fr/nV7CdxBPO8VHuWonf
veax13GoJXbTv65CpXFwB1UjfW7fcFiF9fSaR4TZv9MBZKAn6tavUfgmWUrfpEJo
jBS9CJSk799jKL3kdGtQ
=SSi9
-----END PGP SIGNATURE-----

--Sig_/HhN7UHX_T1r8FPW7F3TK6zy--
