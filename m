From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] korina: count RX DMA OVR as rx_fifo_error
Date: Wed, 02 Jun 2010 06:13:00 -0700 (PDT)
Message-ID: <20100602.061300.233395972.davem@davemloft.net>
References: <1275175416-21267-1-git-send-email-phil@nwl.cc>
	<1275175416-21267-2-git-send-email-phil@nwl.cc>
	<20100529232345.CA3124CD45@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757606Ab0FBNMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:12:50 -0400
In-Reply-To: <20100529232345.CA3124CD45@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Sun, 30 May 2010 01:23:36 +0200

> This way, RX DMA overruns (actually being caused by overrun of the
> 512byte input FIFO) show up in ifconfig output. The rx_fifo_errors
> counter is unused otherwise.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.
