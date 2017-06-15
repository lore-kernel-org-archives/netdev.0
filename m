From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: solos-pci: remove useless variable assignments
Date: Thu, 15 Jun 2017 17:33:34 -0400 (EDT)
Message-ID: <20170615.173334.947301773714825384.davem@davemloft.net>
References: <20170615195621.GA5600@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615195621.GA5600@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 15 Jun 2017 14:56:21 -0500

> Value assigned to variable _data32_ at lines 1254 and 1257 is
> overwritten at line 1260 before it can be used. This makes
> such variable assignments useless.
> 
> Addresses-Coverity-ID: 1227049
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied, thanks.
