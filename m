From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [ipw3945-devel] [PATCH 4/5] iwlwifi: iwl3945 eliminate
	sleepable task queue from context
Date: Fri, 11 Jan 2008 10:01:54 +0800
Message-ID: <1200016915.3530.161.camel@debian.sh.intel.com>
References: <11998765783953-git-send-email-joonwpark81@gmail.com>
	 <1200013607.3530.128.camel@debian.sh.intel.com>
	 <b25c3fa70801101738j512a6189i3e4541bf0348b91f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Joonwoo Park <joonwpark81-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b25c3fa70801101738j512a6189i3e4541bf0348b91f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Fri, 2008-01-11 at 10:38 +0900, Joonwoo Park wrote:
> I should have checked code base, it's my fault.
> it's seems very similar, but I could not made build unfortunately.
> Can you introduce to me how to build it please?
> 
> my build error is here:
> jason@ehus ~/SRC/DRIVERS/iwlwifi $
> KSRC=/home/jason/SRC/LINUX/linux-2.6 make

The version doesn't work on a .24-rc kernel. Can you compile it
with .23?

Thanks,
-yi
