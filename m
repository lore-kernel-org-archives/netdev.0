From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/10] parisc: use RCU to find network device
Date: Tue, 10 Nov 2009 19:26:05 +0100
Message-ID: <4AF9B03D.3010409@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.480041042@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37519 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbZKJS0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:26:11 -0500
In-Reply-To: <20091110175647.480041042@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Another place where RCU can be used instead of read_lock(&dev_base_lo=
ck)
> This is by inspection, don't have platform or cross-build environment
> to validate.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Duplicate of previously posted patch...

http://article.gmane.org/gmane.linux.network/143072



