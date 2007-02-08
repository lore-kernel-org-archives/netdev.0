From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Subject: Re: [PATCH 0/4] spidernet: support for Celleb
Date: Thu, 8 Feb 2007 13:56:52 +0100
Message-ID: <OF4CD93CB2.C6D8AB5B-ONC125727C.0035FE0B-C125727C.00472022@de.ibm.com>
References: <1170894259.2620.325.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, jim@jklewis.com,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:8472 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422860AbXBHM4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 07:56:55 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l18CusjV031318
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 12:56:54 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l18CusXw2252988
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 13:56:54 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l18CurTu019350
	for <netdev@vger.kernel.org>; Thu, 8 Feb 2007 13:56:54 +0100
In-Reply-To: <1170894259.2620.325.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> PHY patch is mostly Ok except I don't like that "medium" variable Jens
> added which isn't used anywhere in sungem_phy. Jens, can you resend a
> version without that ? If you need that variable in spidernet itself,
> then put it there :-)

That was the idea I had first, I'll change that.

> Also, the GMII_* constants, are they standard or 54xx specific ? If the
> later, then change the name to reflect that.

I'll check...

Jens

