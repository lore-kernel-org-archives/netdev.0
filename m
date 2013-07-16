From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3.11-rc1] mlx5 core: Fix __udivdi3 when compiling for
 32 bit arches
Date: Tue, 16 Jul 2013 12:36:58 -0700 (PDT)
Message-ID: <20130716.123658.1660201783834013788.davem@davemloft.net>
References: <1373900205-69711-1-git-send-email-tim.gardner@canonical.com>
	<51E41AB2.3020905@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51E41AB2.3020905-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Mon, 15 Jul 2013 08:52:18 -0700

> On 07/15/13 07:56, Tim Gardner wrote:
>> Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> I reported this last week and Eli wrote:
> 
> "I have this fixed in my tree and we run the driver on i386. I will check on Sunday why it is not in the patches submitted."
> 
> Anyway, the patch works for me.
> 
> Acked-by: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> Reported-by: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
