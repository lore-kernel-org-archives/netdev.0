From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: Re: [PATCH] net: greth: convert to hw_features
Date: Mon, 18 Apr 2011 10:11:58 +0200
Message-ID: <4DABF24E.9010708@gaisler.com>
References: <20110417101547.D59E313A6F@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail202c2.megamailservers.com ([69.49.111.103]:39904 "EHLO
	mail202c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034Ab1DRJa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 05:30:59 -0400
In-Reply-To: <20110417101547.D59E313A6F@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote:
> Note: Driver modifies its struct net_device_ops. This will break if u=
sed for
> multiple devices that are not all the same (if that HW config is poss=
ible).
>=20

True. I will fix this in the future. Not a big problem currently though=
, but thanks for the note and the patch!

Best regards,
Kristoffer Glembo
Aeroflex Gaisler
