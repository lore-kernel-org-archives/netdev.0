From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V2] mellanox: Logging message cleanups
Date: Thu, 08 May 2014 23:42:25 -0400 (EDT)
Message-ID: <20140508.234225.1072761273005912123.davem@davemloft.net>
References: <20140507.154108.567253192690937393.davem@davemloft.net>
	<eceba320507a1895ff8f1a5bd0b7a67839e7b7b0.1399492267.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <eceba320507a1895ff8f1a5bd0b7a67839e7b7b0.1399492267.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Wed,  7 May 2014 12:52:57 -0700

> Use a more current logging style.
> 
> o Coalesce formats
> o Add missing spaces for coalesced formats
> o Align arguments for modified formats
> o Add missing newlines for some logging messages
> o Use DRV_NAME as part of format instead of %s, DRV_NAME to
>   reduce overall text.
> o Use ..., ##__VA_ARGS__ instead of args... in macros
> o Correct a few format typos
> o Use a single line message where appropriate
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Acked-By: Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
