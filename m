From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Fri, 07 Oct 2011 19:04:09 -0700
Message-ID: <4E8FAF99.6000003@gmail.com>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com> <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com> <20110917132153.GA32572@rere.qmqm.pl> <1316476968.2184.14.camel@jtkirshe-mobl> <20110923205621.GA27138@rere.qmqm.pl> <1316839657.2182.136.camel@jtkirshe-mobl> <20111007204701.GA31706@rere.qmqm.pl>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig95315D3F0D542D23C2FD60F6"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36534 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313Ab1JHCEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 22:04:10 -0400
In-Reply-To: <20111007204701.GA31706@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig95315D3F0D542D23C2FD60F6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/07/2011 01:47 PM, =EF=BF=BD wrote:
>>> I see that only a single driver left: igbvf. What's the status
>>> > > on its conversion?
>> > Just waiting on validation at this point to verify the patch we have=
=2E  I
>> > will see if I can get this patch verified and pushed asap.
> Ping?

There is no change as of yet, all I can say is it will be done.  I am
almost at the point of submitting it upstream and fix it later at this
point.  I share any frustration you may have regarding this conversion.


--------------enig95315D3F0D542D23C2FD60F6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOj6+ZAAoJEOVv75VaS+3OkFwP/i3ENas+ENZ7gWCPVBB/I5pO
bO8AnVzXEH5yaXLzBCfwJLw7yudGKWZlnSXWwnjzAYbsBC/lP1N9k8XqS1Nr2k60
qlw6+2HkaeIGNooHAtrezD8L+s1WEjNgYx0+uB+MmNI9wc3oDJN887FUUfXUqKWK
wh1hII8QleJYnXq4MI6evEmHuE388d450II4Eb5D6+9vjU21FxARSvLO8tbhxlz9
nlGLXOoifYgjLQcQgN1hY8udvVNCHoE//Z2+Zx4nLqKIbpqML7BCITGz+SA2e+fo
YVhqwoVytXYr/42j/E4fncfnHhVpG3wox7lBOWrEYJ7vc2rWYtxjDMPMHMWpnLcB
3e16dqkkavvolcQOQtkawf/t62AXyMVbyXM8db6AnBpP85kAg+CLM6JsnGl5ajwu
UYDgGfSIki61YrYetTUE50xdXnLrSDbsO9VDlry0abS8AbOVPl5ZyzIybdFqVkUW
J3ElUt1Mz80gURfIv73xvTvBX0ZzLa6cHiotiNEH8xS/3W6sBHNwYFl8zzf1EASs
Za8nNz8KwnZqDJe6BCgiuU/raFzP5qn0tpo3RwoXTJ7lod1KdiHw9wAUbNl9LSoU
yrV84LR7xZbPw49vOnx7FJpFb8O3BzfkcUs29qbhTMSThgGRS4VdE5ItUo9Lpo7c
EZMWfDR94Q0eMzgrY2aG
=STyg
-----END PGP SIGNATURE-----

--------------enig95315D3F0D542D23C2FD60F6--
