From: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3.11-rc1] mlx5 core: Fix __udivdi3 when compiling for
 32 bit arches
Date: Mon, 15 Jul 2013 14:23:12 -0600
Message-ID: <51E45A30.2050803@canonical.com>
References: <1373900205-69711-1-git-send-email-tim.gardner@canonical.com> <51E41AB2.3020905@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51E41AB2.3020905-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/15/2013 09:52 AM, Randy Dunlap wrote:
> On 07/15/13 07:56, Tim Gardner wrote:
>> Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> Signed-off-by: Tim Gardner
>> <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> I reported this last week and Eli wrote:
> 
> "I have this fixed in my tree and we run the driver on i386. I will
> check on Sunday why it is not in the patches submitted."
> 
> Anyway, the patch works for me.
> 
> Acked-by: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> Reported-by: Randy
> Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> 

I figured someone must have seen it, but a cursory Google search on
"mlx5 __udivdi3" failed to turn up anything.

rtg
-- 
Tim Gardner tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
