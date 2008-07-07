From: Jan-Bernd Themann <ossthema-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BUG] 2.6.26-rc8-git2 - powerpc - circular locking dependency detected with net/ehea driver
Date: Mon, 7 Jul 2008 10:08:08 +0100
Message-ID: <200807071108.09616.ossthema@de.ibm.com>
References: <486A2553.1090207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Kamalesh Babulal <kamalesh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <486A2553.1090207-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kamalesh,

where you able to reproduce this problem with the patches applied
we posted on friday?

Regards,
Jan-Bernd

On Tuesday 01 July 2008 14:38, Kamalesh Babulal wrote:
> Hi,
> 
> circular locking dependency is detected, while booting the
> powerpc box with the 2.6.26-rc8-git2 kernel.
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.26-rc8-git2 #1
> -------------------------------------------------------
