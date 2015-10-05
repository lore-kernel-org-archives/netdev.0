From: Jon Ringle <jon@ringle.org>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Mon, 5 Oct 2015 07:57:00 -0400 (EDT)
Message-ID: <alpine.DEB.2.10.1510050755120.27553@jring-w510-7m3g.gridpoint.com>
References: <1443699801-8888-1-git-send-email-jon@ringle.org> <20151005.035443.992186445847147964.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jon@ringle.org, broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151005.035443.992186445847147964.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 5 Oct 2015, David Miller wrote:

> From: jon@ringle.org
> Date: Thu,  1 Oct 2015 07:43:20 -0400
> 
> > From: Jon Ringle <jringle@gridpoint.com>
> > 
> > This commit allows installing a custom reg_update_bits function for cases where
> > the hardware provides a mechanism to set or clear register bits without a
> > read/modify/write cycle. Such is the case with the Microchip ENCX24J600.
> > 
> > Signed-off-by: Jon Ringle <jringle@gridpoint.com>
> 
> Applied.

Thanks David. However, I've sent a v3 patch, and also expecting feedback 
from Mark Brown on the regmap portion of it.

-Jon
