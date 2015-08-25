From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Tue, 25 Aug 2015 10:39:16 +0200
Message-ID: <20150825083916.GB5046@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
 <20150822083916.GA17408@calimero.vinschen.de>
 <20150822112334.GB24519@electric-eye.fr.zoreil.com>
 <20150824073348.GL19683@calimero.vinschen.de>
 <20150824233346.GA30812@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ftEhullJWpWg/VHq"
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:40803 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139AbbHYIjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 04:39:21 -0400
Content-Disposition: inline
In-Reply-To: <20150824233346.GA30812@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 25 01:33, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> > On Aug 22 13:23, Francois Romieu wrote:
> [...]
> > > Sorry, my english was really bad:
> > >=20
> > > the code should propagate failure when rtl8169_reset_counters and
> > > rtl8169_update_counters *simultaneously* fail.
> >=20
> > Uhm... sorry, but that still doesn't answer the question.  As you can
> > see in my patch, the initalization at open time is already encapsulated
> > in a function rtl8169_init_counter_offsets.=20
>=20
> I have read your patch, I have already answered the question and I have
> already said that it wasn't a showstopper.

Ok.  I hope v4 of the patch is ok?


Thanks,
Corinna

--ftEhullJWpWg/VHq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV3Cm0AAoJEPU2Bp2uRE+gDagQAIAJRb19nYRqzyAF8b+LvN5U
b8VrFU5WFG9A1LwpMqJLsXUAJoRdRQNOri9PbYEmafZWj7ITGUeqI38+SBb5B9XO
mAy/c2SVCOJavNkhXMyXJyVNNHpyVRKmGaoQPBnD+LvEqKUYohFGpjeEeIaVuu/E
CajGkAd2LuxKfkrJSAgzQKRax54LNlMf5cnKHCtFNx0jX+srK4qBviG0r8FiQ1LT
eL0eD9Jdy4lbPRekXRkVE7/E/zhASBbuXev0HFMympsYwhRvi9RhLzwym0ufs5Nl
hJ/7T2HmLm+dEpsBTEMfh+kdDPApB8LDvYdU8FZP3m2qg8fjOes7QS6lfSQEIxoO
V7PZ0ndtTKntuTT1Ioh6OamVDxdxrwy3q7FnXlC35RESk0ep8X3dHmfhiBWo7MWY
cpYg+L7P/xgN9rYWZetX/o6Cj8lybMMOvpziR9LqWlZNuU+DJSFr3spoQ3+gkz3v
E81PHzlrl87ihC9D99lU+iigt7bDJLak5ex7smzVVx9lNC1rLMUBOxwvZzIsY3Q2
ybv6mQArdwsQPnWjWCi5JhCvqnhWNLLoo6FHqoAU1Rjz8WoOCq/I258tyuU8LNao
/9sUfoFgKPUfZ9RzR+QSwqGYMHsxdNa+EE6U6c4S73AKPGOtxjP7S+EaOvLzqKlH
ME+6YL6onPPmHtl/XnbF
=JkpI
-----END PGP SIGNATURE-----

--ftEhullJWpWg/VHq--
