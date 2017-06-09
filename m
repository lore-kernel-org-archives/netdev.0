From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] mlx4 drivers: version update
Date: Fri, 09 Jun 2017 17:26:53 -0400
Message-ID: <1497043613.7171.227.camel@redhat.com>
References: <1496841975-7728-1-git-send-email-tariqt@mellanox.com>
         <20170607.153333.2137691985139660875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170607.153333.2137691985139660875.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-07 at 15:33 -0400, David Miller wrote:
> From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Date: Wed,  7 Jun 2017 16:26:12 +0300
> 
> > This patchset contains version updates for the MLX4 drivers:
> > Core, EN, and IB.
> > 
> > Just like we've done in mlx5, we modify the outdated driver
> > version (reported in ethtool for example).
> > This better reflects the current driver state, and removes the
> > redundant date string.
> > We are not going to change this frequently or even use it.
> > 
> > I include the IB patch in this series as it has similar subject
> > and content.
> > It does not cause any kind of conflict with Doug's tree.
> > The rdma mailing list is CCed.
> > Please let me know if I need to submit this differently.
> 
> Ok, series applied.
> 
> Doug, let me know if you want to handle this differently or want
> me to change something.
> 
> Thanks.

You've got it, I'll skip it, it's all good.

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
