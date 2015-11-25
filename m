From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
Date: Wed, 25 Nov 2015 11:29:02 -0500 (EST)
Message-ID: <20151125.112902.963518845629277747.davem@davemloft.net>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz,
 tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:01 -0500

> The unified hierarchy memory controller is going to use this jump
> label as well to control the networking callbacks. Move it to the
> memory controller code and give it a more generic name.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
