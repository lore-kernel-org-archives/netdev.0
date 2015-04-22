From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Tue, 21 Apr 2015 17:18:11 -0700
Message-ID: <1429661891.2638.199.camel@jtkirshe-mobl>
References: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1+HAMHy3Je/eWrQmDCbA"
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43953 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933415AbbDVASM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 20:18:12 -0400
In-Reply-To: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1+HAMHy3Je/eWrQmDCbA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-04-21 at 16:20 -0700, Cong Wang wrote:
> Fixes: 5536d2102a2d ("igb: Combine q_vector and ring allocation into a
> single function")
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Cong, I will add your patch to my queue.

--=-1+HAMHy3Je/eWrQmDCbA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVNujDAAoJEOVv75VaS+3OqdwP/3BCVJ+ArZy66UfkHwo2OCRZ
NnBmBtdyCrt9AAQfZ5SM13weu6wFP8CjF2F+DYNy/e00dr3K71Ifwmp6TIJ3N6BJ
ow365morh6q6EspMfoBomCzSH9YBqXqsW2Xx2OJmw+xHowUi05a0pGetB6Ma4dWG
rEYyk6SatJbGAcRZjujQ3GExR6hqA61/yc/+RU1E24tltg9JoYbQhR34sKnJTnc8
6qeo4HdzzCE9pihcJ7KQk8Vgw+2+PyNY3WW8He3VfdlP5qp9J40Bv+XcLStOZs2U
u8xmLUAqlGnluLEee+UAWs+QLqiqidgAVfKZ8OH7QMS1SuYP+1rJPbUfznXFi9OG
laQeyDyHVqbx4sxbqtHN2fsUp2iCfabGhLoxc0ir8zfWrRKmLK4T1QzR/RV8BC8y
Tae5ZE8lb3kbfSjgOzOy3FY4FGu29B619s5a+ds0sdwxaH5jHEYjlz+su5pIYwWp
SdW0YkKEHtMLTPbzLq/H9Y2NrP2luE4vqB+7nrYnLdLnBTxcnhMyZIw2sBW361Ad
wNkm18ltjMeA/rNGe4KAi/BOuNGVYLpkK2cHl8uAP7AieyvWRX3dvfUQ7DeTulO6
dK6MAWoP2X1t3yGzEQtFcLN0IPU8SDVpVSQnX8qRizbfwm0PSLN9xxOyX7AjQpVT
tFyjzTmXUibzQU6THvJc
=Sa3D
-----END PGP SIGNATURE-----

--=-1+HAMHy3Je/eWrQmDCbA--
