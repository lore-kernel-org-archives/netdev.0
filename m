From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 12/14] mm: memcontrol: move socket code for unified
 hierarchy accounting
Date: Fri, 20 Nov 2015 15:44:45 +0300
Message-ID: <20151120124445.GE31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-13-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, Andrew Morton
	<akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko
	<mhocko@suse.cz>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-13-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:31PM -0500, Johannes Weiner wrote:
> The unified hierarchy memory controller will account socket
> memory. Move the infrastructure functions accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
