From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool : NFC corrections again
Date: Thu, 14 Jul 2011 02:01:08 +0100
Message-ID: <1310605268.2756.15.camel@bwh-desktop>
References: <1309423280.15040.2.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?=
	<sebastian.belden@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10019 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1GNBBM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:01:12 -0400
In-Reply-To: <1309423280.15040.2.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-30 at 10:41 +0200, Sebastian P=C3=B6hn wrote:
> This patch:
> # Adds an alias for ip4 called l4data pointing to spi (first 4 Layer =
4
> bytes)
> # [TRIVIAL] Corrects the permutation of dst and src for ethernet
> # Suggests to always set the ip_ver field of usr_ip to ETH_RX_NFC_IP4=
 at
> least as long there is no opportunity to use others than IPv4 and the=
re
> is no frontend option to enter ip_ver.
[...]

Applied.  Sorry for the delay.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

