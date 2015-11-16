From: David Miller <davem@davemloft.net>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 16:33:27 -0500 (EST)
Message-ID: <20151116.163327.500953242093794786.davem@davemloft.net>
References: <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
	<20151116.161746.1472467067664450149.davem@davemloft.net>
	<CAHmME9qDJnfJgerxwwG8_dMvse7oim=sDdPzQo=DRi_S0Ym=Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbbKPVd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 16:33:29 -0500
In-Reply-To: <CAHmME9qDJnfJgerxwwG8_dMvse7oim=sDdPzQo=DRi_S0Ym=Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 16 Nov 2015 22:28:52 +0100

> I'm making a simpler replacement for IPSec that operates as an
> device driver on the interface level

Someone already did a Linux implemenation of exactly that two decades
ago, we rejected that design and did what we did.
