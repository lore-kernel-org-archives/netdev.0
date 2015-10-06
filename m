From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Mon, 05 Oct 2015 23:21:48 -0700 (PDT)
Message-ID: <20151005.232148.28609721470208031.davem@davemloft.net>
References: <alpine.DEB.2.10.1510050755120.27553@jring-w510-7m3g.gridpoint.com>
	<20151005.061609.75433802286337666.davem@davemloft.net>
	<20151005142531.GS12635@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151005142531.GS12635@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Brown <broonie@kernel.org>
Date: Mon, 5 Oct 2015 15:25:31 +0100

> On Mon, Oct 05, 2015 at 06:16:09AM -0700, David Miller wrote:
> 
>> >> Applied.
> 
>> > Thanks David. However, I've sent a v3 patch, and also expecting feedback 
>> > from Mark Brown on the regmap portion of it.
> 
>> Please send me relative changes from v2 to v3, thanks.
> 
>> Sorry about that.
> 
> Ugh, this is a mess :(  Can you please drop this patch instead?

I can't just "drop" changes.  Once a commit hits my tree it is part
of the permanent record.

The easiest thing to do is to send a relative fix, and that's why
I have asked for exactly that.
