From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/6] netprio_cgroup: use IS_ENABLED() and family
Date: Wed, 01 Feb 2012 15:06:53 +0800
Message-ID: <4F28E48D.3040505@cn.fujitsu.com>
References: <4F28E1D1.900@cn.fujitsu.com>	<4F28E203.10502@cn.fujitsu.com> <20120201.015954.2098592611164231843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120201.015954.2098592611164231843.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

14:59, David Miller wrote:
> 
> Do not mix genuine bug fixes and cleanups.
> 
> Otherwise I cannot apply your bug fixes to the 'net' tree.
> 
> Seperate things out, submit only pure bug fixes first, then
> later once those changes propagate you can submit the cleanups.
> 

I did seperate them out, so the first three patches are fixes,
and others are cleanups. I can resend cleanup patches once
fixes hit mainline.
