From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Mon, 05 Oct 2015 03:54:43 -0700 (PDT)
Message-ID: <20151005.035443.992186445847147964.davem@davemloft.net>
References: <1443699801-8888-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443699801-8888-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jon@ringle.org
Date: Thu,  1 Oct 2015 07:43:20 -0400

> From: Jon Ringle <jringle@gridpoint.com>
> 
> This commit allows installing a custom reg_update_bits function for cases where
> the hardware provides a mechanism to set or clear register bits without a
> read/modify/write cycle. Such is the case with the Microchip ENCX24J600.
> 
> Signed-off-by: Jon Ringle <jringle@gridpoint.com>

Applied.
