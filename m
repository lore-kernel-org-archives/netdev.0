From: Jan-Pascal van Best <janpascal@vanbest.org>
Subject: Re: [PATCH net-next 09/15] drivers/net: delete old 8 bit ISA Racal
 ni5010 support.
Date: Tue, 22 Jan 2013 20:59:14 +0100
Message-ID: <50FEEF92.3000809@vanbest.org>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com> <1358819182-28032-10-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Mohr <andi@lisas.de>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from strictvertrouwelijk.xs4all.nl ([83.163.6.54]:51072 "EHLO
	nogrod.vanbest.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048Ab3AVUIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:08:14 -0500
In-Reply-To: <1358819182-28032-10-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Hi Paul,

Although for me personally it'll be a shock not be able to run the latest
kernel on my legacy system I keep up especially for this ISA card, Andreas
and I cannot seriously oppose removing this driver from the mainline
kernel. It's probably more than a decade and a half ago since anyone used
an NI5010 in production, which makes it time to move on...

By the way, Andreas promises to keep his stable  of NI5010 cards forever,
and still has a BNC network in active (if loathed!) service.

Thanks for your work on keeping the kernel net drivers in good order!

Jan-Pascal


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJQ/u+SAAoJEAD3KLeQ59brsAYH/0neYIXG2BLkghlc9rOakSYc
1oLJposC5WhMlON57xHD0zFh9tYGRV910k0YLuwlUBAb78gsPasnWHqZJ/9bd666
F/B7vi1uaLpT6lkem3xWx8FAkoiUb2i8RBccOseRiUPdrqqm0AKflygZ1RGhoZad
fzr6evOcbd0M6E1/bUNO79oayCN69NLhkqf7thBx/bT5jgKXD0H4RC3MoFghhqS1
dU0be/1Vc9VMc9UnLAO0BQOPzXJRLjAY1IFD4YZUgJYs/u6DnsRF0agxvsADf+Gx
ubHij5R/d+PuMpNEejtE3sfm9AEDpvN+rq3UAnr9y1xeIPr/D/0cKUL94LSpnTU=
=DBl6
-----END PGP SIGNATURE-----
