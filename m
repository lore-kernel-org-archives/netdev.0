From: David Miller <davem@davemloft.net>
Subject: Re: [kj] is_power_of_2 in net/core/neighbour.c
Date: Fri, 24 Aug 2007 22:28:07 -0700 (PDT)
Message-ID: <20070824.222807.102129512.davem@davemloft.net>
References: <1187010227.7273.16.camel@merlin.linuxcoe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	kernel-janitors@lists.osdl.org
To: vigneshbabu@gmail.com, vignesh.babu@wipro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753773AbXHYF2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:28:09 -0400
In-Reply-To: <1187010227.7273.16.camel@merlin.linuxcoe.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: vignesh babu <vignesh.babu@wipro.com>
Date: Mon, 13 Aug 2007 18:33:47 +0530

> Replacing n & (n - 1) for power of 2 check by is_power_of_2(n)
> 
> Signed-off-by: vignesh babu <vignesh.babu@wipro.com>

Patch applied, thanks.
