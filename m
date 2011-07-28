From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix bug caused by
 87c288c6e9aa31720b72e2bc2d665e24e1653c3e
Date: Wed, 27 Jul 2011 22:43:29 -0700 (PDT)
Message-ID: <20110727.224329.2111644039107263213.davem@davemloft.net>
References: <1311674593.17190.7.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com
To: sebastian.belden@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892Ab1G1Fnd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:43:33 -0400
In-Reply-To: <1311674593.17190.7.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
Date: Tue, 26 Jul 2011 12:03:13 +0200

> commit 87c288c6e9aa31720b72e2bc2d665e24e1653c3e "gianfar: do vlan cle=
anup" has two issues:
> # permutation of rx and tx flags
> # enabling vlan tag insertion by default (this leads to unusable conn=
ections on some configurations)
>=20
> If VLAN insertion is requested (via ethtool) it will be set at an oth=
er point ...
>=20
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

Applied.
