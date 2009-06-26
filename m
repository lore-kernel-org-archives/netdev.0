From: Jesper Dangaard Brouer <hawk-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Fri, 26 Jun 2009 21:18:24 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0906262100210.14848@ask.diku.dk>
References: <1245845367.24921.3.camel@localhost.localdomain>
 <5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com>
 <1245930729.24921.67.camel@localhost.localdomain> <20090625.161046.19938291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <jdb-4UpuNZONu4c@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	catalin.marinas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090625.161046.19938291.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Jun 2009, David Miller wrote:

> However, could you formally resubmit just the networking bits
> as that would make life a lot easier for me.

As maintainer of now three kernel subsystems, you are allowed to push work 
my way... And thanks to StGit (http://www.procode.org/stgit/) picking the 
patchset a part is easy :-) (kudos to Catalin Marinas)

I'll resubmit the patches to you and netdev, to limit the spam effect...

Thus, you are getting 5 of the patches 02, 03, 04, 06 and 07.  And I have 
added the Acked-by's.  And Patrick has already picked up the netfilter 
patch.

> Thanks a lot Jesper!
You are welcome :-)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
