From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/4] [IrDA] stir4200, switching to the kthread API
Date: Thu, 25 May 2006 11:01:54 -0700
Message-ID: <20060525110154.32084ca6@localhost.localdomain>
References: <20060525061944.GC24611@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49322 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030302AbWEYSCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 14:02:07 -0400
To: Samuel Ortiz <samuel@sortiz.org>
In-Reply-To: <20060525061944.GC24611@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006 06:19:44 +0000
Samuel Ortiz <samuel@sortiz.org> wrote:

> stir4200 uses a kernel thread for its TX/RX operations, and it is now
> converted to the kernel kthread API.
> Tested on an STIR4200 based dongle.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
> 

Looks fine.
