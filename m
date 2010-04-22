From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][RESEND] ehea: error handling improvement
Date: Wed, 21 Apr 2010 22:36:20 -0700 (PDT)
Message-ID: <20100421.223620.257172362.davem@davemloft.net>
References: <201004211110.55986.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, themann@de.ibm.com
To: tklein@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004211110.55986.tklein@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Klein <tklein@de.ibm.com>
Date: Wed, 21 Apr 2010 11:10:55 +0200

> Reset a port's resources only if they're actually in an error state
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> ---
> 
> Patch created against net-2.6

I thought you were sorry for wasting my time and that you were going
to follow the directions I gave you last time, and I quote:

--------------------
3) These are not appropriate for net-2.6 as we are deep in
   the -rcX series at this point and only the most diabolical
   bug fixes are appropriate.  Therefore, please generate these
   against net-next-2.6, thanks.
--------------------

And here you are generating your patches against net-2.6.  Heck, you
even feel it's worth mentioning explicitly.

Lucky for you the patches happen to apply cleanly to net-next-2.6 so
I've put them there.
