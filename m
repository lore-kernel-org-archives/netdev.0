From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] WAN: protect HDLC proto list while insmod/rmmod
Date: Thu, 22 May 2008 06:27:20 -0400
Message-ID: <48354A88.7060905@garzik.org>
References: <20080424.065555.30390704.davem@davemloft.net>	<m3ve27nfpx.fsf@maximus.localdomain>	<20080424214457.1d5a1655@the-village.bc.nu>	<20080512.033244.153113922.davem@davemloft.net>	<m3lk2djbq3.fsf@maximus.localdomain> <m3ve1agrek.fsf_-_@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alan@lxorguk.ukuu.org.uk, David Miller <davem@davemloft.net>,
	paulkf@microgate.com, jchapman@katalix.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60837 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764570AbYEVK2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:28:00 -0400
In-Reply-To: <m3ve1agrek.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> WAN: protect protocol list in hdlc.c with RTNL.
>    =20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

applied


