From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Wed, 13 Jul 2011 17:52:08 -0700
Message-ID: <20110713175208.1aac853f@nehalam.ftrdhcpuser.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50468 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab1GNAwI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:52:08 -0400
In-Reply-To: <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> Remove it, as it indirectly exposes netdev features. It's not used in
> iproute2 (2.6.38) - is anything else using its interface?
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Once again, users need to be allowed to do arbitrary combination
of new and old releases of kernel and userspace.


