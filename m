From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PULL REQUEST] Please pull rdma.git
Date: Thu, 31 Mar 2016 22:18:47 -0400 (EDT)
Message-ID: <20160331.221847.53272383417094737.davem@davemloft.net>
References: <20160323105708.GP25216@leon.nu>
	<56F29C32.305@redhat.com>
	<20160331233828.GE2670@leon.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: leon-2ukJVAZIZ/Y@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160331233828.GE2670-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Date: Fri, 1 Apr 2016 02:38:28 +0300

> On Wed, Mar 23, 2016 at 09:37:54AM -0400, Doug Ledford wrote:
>> On 03/23/2016 06:57 AM, Leon Romanovsky wrote:
>> > On Sat, Mar 19, 2016 at 02:37:08PM -0700, Linus Torvalds wrote:
>> >> So the *best* situation would be:
>> >>
>> >>  - your two groups talk it over, and figure out what the common commits are
>> >>
>> >>  - you put those common commits as a "base" branch in git
>> >>
>> >>  - you ask the two upper-level maintainers to both pull that base branch
>> >>
>> >>  - you then make sure that you send the later patches (whether as
>> >> emailed patches or as pull requests) based on top of that base branch.
>> > 
>> > Hi David and Doug,
>> > 
>> > Are you OK with the approach suggested by Linus?
>> > We are eager to know it, so we will adopt it as soon
>> > as possible in our development flow.
>> > 
>> > The original thread [1].
>> > 
>> > [1] http://thread.gmane.org/gmane.linux.drivers.rdma/34907
>> > 
>> > Thanks.
>> > 
>> 
>> I'm fine with it.  Since I happen to use topic branches to build my
>> for-next from anyway, I might need to be the one that Dave pulls from
>> versus the other way around.
> 
> Resending to linux-netdev.
> 
> David,
> Can you please express your opinion about Linus's suggestion to
> eliminate merge conflicts in Mellanox related products?

Sure, sounds fine.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
