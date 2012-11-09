From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: packet_mmap: update doc to
 implementation status
Date: Fri, 09 Nov 2012 16:46:04 -0500 (EST)
Message-ID: <20121109.164604.1634366397857520551.davem@davemloft.net>
References: <20121108123700.GA25799@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ronny.meeus@gmail.com, uaca@alumni.uv.es, johann.baudy@gnu-log.net,
	netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756293Ab2KIVqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:46:09 -0500
In-Reply-To: <20121108123700.GA25799@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Thu, 8 Nov 2012 13:37:01 +0100

> This improves the packet_mmap.txt document in the following ways:
> 
>  * Add initial information about different TPACKET versions
>  * Add initial information about packet fanout
>  * Add pointer to BPF document (since this also could be of interest)
>  * 'Fix' minor, rather cosmetic things
> 
> Information partially taken from related commit messages.
> 
> Reported-by: Ronny Meeus <ronny.meeus@gmail.com>
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Thanks for doing this, applied.
