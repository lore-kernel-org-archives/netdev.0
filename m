From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg
 is marked volatile
Date: Tue, 06 Oct 2015 06:26:08 -0700 (PDT)
Message-ID: <20151006.062608.1641286536180909103.davem@davemloft.net>
References: <20151005.232956.105884641412802470.davem@davemloft.net>
	<20151006101305.GG12635@sirena.org.uk>
	<ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: jonringle@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Ringle <jonringle@gmail.com>
Date: Tue, 6 Oct 2015 08:50:43 -0400

> 1) David, revert the following from net-next:
> $ git revert 9886ce2b9d4e5a8bb3d78d0f7eff3c0f1ed58d67
> $ git revert 04fbfce7a222327b97ca165294ef19f0faa45960
> $ git revert 7741c373cf3ea1f5383fa97fb7a640a429d3dd7c

Applied, thanks.
