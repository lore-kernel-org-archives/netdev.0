From: David Miller <davem@davemloft.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 0/2 v3] changed irq handling for
 at86rf230
Date: Mon, 15 Apr 2013 22:34:54 -0400 (EDT)
Message-ID: <20130415.223454.740613305714900291.davem@davemloft.net>
References: <cover.1366012862.git.sascha@ps.nvbi.de>
	<20130415.154931.1534207963525784709.davem@davemloft.net>
	<20130416014419.GF29789@ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sascha@ps.nvbi.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: werner@almesberger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935111Ab3DPCe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 22:34:56 -0400
In-Reply-To: <20130416014419.GF29789@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Werner Almesberger <werner@almesberger.net>
Date: Mon, 15 Apr 2013 22:44:19 -0300

> David Miller wrote:
>> I'd like to see some reviews of this patch series, thanks.
> 
> Sascha and I discussed the functional aspects of his changes a
> while ago and I'm satisfied with the way he has done things now.
> I also believe his approach to be technically sound.
> 
> Furthermore, I merged his changes into my atben driver (which
> uses level-triggered interrupts while Sascha's platform is
> edge-triggered), and it passed some light testing.

"Acked-by: Werner ..." is most useful to me.
