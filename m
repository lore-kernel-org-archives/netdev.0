From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/eicon: use standard __init,__exit function markup
Date: Fri, 27 Apr 2012 00:04:08 -0400 (EDT)
Message-ID: <20120427.000408.889398727032151984.davem@davemloft.net>
References: <201204241556.03516.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mac@melware.de, isdn@linux-pingi.de
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204241556.03516.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 24 Apr 2012 15:56:03 -0700

> Remove the custom DIVA_{INIT,EXIT}_FUNCTION defines and use
> the standard __init,__exit markup.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
