From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] liquidio: mark expected switch fall-through in
 octeon_destroy_resources
Date: Thu, 19 Oct 2017 13:28:26 +0100 (WEST)
Message-ID: <20171019.132826.998756222988658530.davem@davemloft.net>
References: <20171017185920.GA16976@embeddedor.com>
        <20171017190145.GA17015@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, garsilva@embeddedorcom
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017190145.GA17015@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Tue, 17 Oct 2017 14:01:45 -0500

> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied to net-next.
