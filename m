From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [SLHC 2/4] Convert to kzalloc
Date: Thu, 13 Jul 2006 18:08:55 +0100
Message-ID: <20060713170855.GA21538@infradead.org>
References: <20060713111048.GA19938@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:16828 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030255AbWGMRJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 13:09:00 -0400
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20060713111048.GA19938@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 12:10:48PM +0100, Ralf Baechle wrote:
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

at the same time please remove the useless casts of the kmalloc/kzalloc
return value.

