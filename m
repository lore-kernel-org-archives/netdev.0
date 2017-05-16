From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 14:03:22 -0400
Message-ID: <1494957802.3259.131.camel@redhat.com>
References: <1494952963.3259.109.camel@redhat.com>
         <20170516.124945.386235742645153398.davem@davemloft.net>
         <1494955244.3259.130.camel@redhat.com>
         <20170516.133644.850927380166261577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
        hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516.133644.850927380166261577.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-05-16 at 13:36 -0400, David Miller wrote:
> From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 16 May 2017 13:20:44 -0400
> 
> > Anyway, we're just talking out what happened, when what we really
> need
> > to focus on is moving forward.  Again, your thoughts on marking SMC
> > EXPERIMENTAL until it's fixed up and unfreezing the API in case we
> need
> > to adjust it to work on different link layers?
> 
> Something like:
> 
>         http://patchwork.ozlabs.org/patch/762803/
> 
> with the addition of the EXPERIMENTAL dependency?
> 
> Sure.

Perfect.  I assume you'll submit it since it's in your patchworks?

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
