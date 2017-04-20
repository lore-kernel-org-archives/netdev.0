From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH net-next 00/16] Mellanox, mlx5 RDMA net device support
Date: Thu, 20 Apr 2017 14:41:17 -0400
Message-ID: <1492713677.3041.3.camel@redhat.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
         <20170417.110851.1496380796999919507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        leonro@mellanox.com, erezsh@mellanox.com,
        jgunthorpe@obsidianresearch.com,
        niranjana.vishwanathapura@intel.com
To: David Miller <davem@davemloft.net>, saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946460AbdDTSlT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 14:41:19 -0400
In-Reply-To: <20170417.110851.1496380796999919507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 11:08 -0400, David Miller wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Thu, 13 Apr 2017 06:36:50 +0300
> 
> > This series provides the lower level mlx5 support of RDMA netdevice
> > creation API [1] suggested and introduced by Intel's HFI OPA VNIC
> > netdevice driver [2], to enable IPoIB mlx5 RDMA netdevice creation.
> 
> Series applied to net-next.

I've pulled Dave's net-next into a branch in my tree for the IPoIB
patches to go on top of so that way it can hold the final touchup patch
without any conflicts anywhere.

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
