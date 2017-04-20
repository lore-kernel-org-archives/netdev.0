From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 00/16] Mellanox, mlx5 RDMA net device support
Date: Thu, 20 Apr 2017 16:45:43 -0400
Message-ID: <1492721143.3041.20.camel@redhat.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
         <20170417.110851.1496380796999919507.davem@davemloft.net>
         <1492713677.3041.3.camel@redhat.com>
         <20170420184955.GU14088@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org,
        niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170420184955.GU14088-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-20 at 21:49 +0300, Leon Romanovsky wrote:
> On Thu, Apr 20, 2017 at 02:41:17PM -0400, Doug Ledford wrote:
> > 
> > On Mon, 2017-04-17 at 11:08 -0400, David Miller wrote:
> > > 
> > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Date: Thu, 13 Apr 2017 06:36:50 +0300
> > > 
> > > > 
> > > > This series provides the lower level mlx5 support of RDMA
> > > > netdevice
> > > > creation API [1] suggested and introduced by Intel's HFI OPA
> > > > VNIC
> > > > netdevice driver [2], to enable IPoIB mlx5 RDMA netdevice
> > > > creation.
> > > 
> > > Series applied to net-next.
> > 
> > I've pulled Dave's net-next into a branch in my tree for the IPoIB
> > patches to go on top of so that way it can hold the final touchup
> > patch
> > without any conflicts anywhere.
> 
> Thanks,
> 
> How and when do you want us to forward it?

The branch in question is already pushed for 0day and linux-next
testing, so you can send the fixup patch to linux-rdma based upon my
k.o/for-4.12-rdma-netdevice branch any time.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
