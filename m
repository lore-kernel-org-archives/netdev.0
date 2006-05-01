From: Joseph Jezak <josejx@gentoo.org>
Subject: Re: wireless softmac origin (net/ieee80211/softmac)
Date: Mon, 01 May 2006 10:30:19 -0400
Message-ID: <44561B7B.5020509@gentoo.org>
References: <d0383f90605010719p616243d0l8da568c02815f504@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ian Brown <ianbrn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc12.comcast.net ([216.148.227.152]:4553 "EHLO
	rwcrmhc12.comcast.net") by vger.kernel.org with ESMTP
	id S932110AbWEAOaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 10:30:23 -0400
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <d0383f90605010719p616243d0l8da568c02815f504@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Ian Brown wrote:
> Hello,
> I am looking at 2.6.17-rc3 kernel.
> I wonder: what is the origin of softmac in
> 2.6.17-rc3 kernel ?
> I see in the *.c files under that folder:
> Copyright (c) 2005, 2006 Johannes Berg <johannes@sipsolutions.net>
> *                          Joseph Jezak <josejx@gentoo.org>
> *                          Larry Finger <Larry.Finger@lwfinger.net>
> *                          Danny van Dyk <kugelfang@gentoo.org>
> *                          Michael Buesch <mbuesch@freenet.de>
> 
> Is this softmac layer was written from scratch ? or was it
> taken (fully/partially) from softmac in the devicescape linux kernel
> stack ?
> http://devicescape.com/
> 
> Best,
> IB
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

It was written from scratch.

- -Joe
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEVht7wGq7BLLARfoRAspnAJ9vQC8EUnzN9efWpJZijVNDnsSUIwCfUiVZ
1nsWLEQr+iA0BG18tUKoY8c=
=GRht
-----END PGP SIGNATURE-----
