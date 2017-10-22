From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: x25: mark expected switch fall-throughs
Date: Sun, 22 Oct 2017 03:10:36 +0100 (WEST)
Message-ID: <20171022.031036.782328191930921544.davem@davemloft.net>
References: <20171020173752.GA10123@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020173752.GA10123@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Fri, 20 Oct 2017 12:37:52 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
