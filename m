From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 10/14] mm: memcontrol: generalize the socket accounting
 jump label
Date: Sat, 14 Nov 2015 16:29:43 +0300
Message-ID: <20151114132943.GK31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-11-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>,
	<netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-11-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:29PM -0500, Johannes Weiner wrote:
> The unified hierarchy memory controller is going to use this jump
> label as well to control the networking callbacks. Move it to the
> memory controller code and give it a more generic name.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
