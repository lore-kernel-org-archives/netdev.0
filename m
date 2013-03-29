From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] atl1e: drop pci-msi support because of packet
 corruption
Date: Fri, 29 Mar 2013 15:35:58 -0400 (EDT)
Message-ID: <20130329.153558.994660857588648339.davem@davemloft.net>
References: <20130329041050.GA29040@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rebelyouth.hacklab@gmail.com,
	xiong@qca.qualcomm.com, christian.suenkenberg@student.kit.edu,
	sven@svenhartge.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756282Ab3C2TgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:36:00 -0400
In-Reply-To: <20130329041050.GA29040@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 29 Mar 2013 05:10:50 +0100

> Usage of pci-msi results in corrupted dma packet transfers to the hos=
t.
>=20
> Reported-by: rebelyouth <rebelyouth.hacklab@gmail.com>
> Cc: Huang, Xiong <xiong@qca.qualcomm.com>
> Tested-by: Christian S=FCnkenberg <christian.suenkenberg@student.kit.=
edu>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
