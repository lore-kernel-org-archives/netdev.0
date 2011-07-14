From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 09/10] net: remove /sys/class/net/*/features
Date: Wed, 13 Jul 2011 17:50:37 -0700
Message-ID: <20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50419 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204Ab1GNAuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:50:37 -0400
In-Reply-To: <ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> The same information and more can be obtained by using ethtool
> with ETHTOOL_GFEATURES.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>

Changing user visible API has to go through a longer process
such as putting it in feature-removal-schedule.txt for a while
(at couple of releases) before removing.
