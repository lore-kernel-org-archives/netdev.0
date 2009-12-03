From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 01/10] e1000e: remove use of skb_dma_map
 from e1000e driver
Date: Thu, 03 Dec 2009 07:13:05 +0100
Message-ID: <4B1756F1.2080402@gmail.com>
References: <20091203024519.2232.6084.stgit@localhost.localdomain> <20091202.203330.49818890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46014 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbZLCGNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:13:21 -0500
In-Reply-To: <20091202.203330.49818890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> All 10 patches applied.
>=20
> Alexander et al., thanks for following up on this.

Excellent, time for new benchs :)

