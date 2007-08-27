From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Remove softirq scheduling from pktgen [PATCH]
Date: Mon, 27 Aug 2007 18:18:46 +0100
Message-ID: <20070827171846.GA2264@infradead.org>
References: <18131.623.945573.425948@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:53834 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394AbXH0RSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 13:18:51 -0400
Content-Disposition: inline
In-Reply-To: <18131.623.945573.425948@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 27, 2007 at 06:57:19PM +0200, Robert Olsson wrote:
> 
> 
> Hello, It's not a job for pktgen.

Please also kill the do_softirq export while you're at it.

