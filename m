From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ip6_tunnel: Correct tos value in collect_md mode
Date: Sun, 18 Jun 2017 23:57:40 -0400 (EDT)
Message-ID: <20170618.235740.1246878970570555030.davem@davemloft.net>
References: <1497670685-3118-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, petedaws@gmail.com
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497670685-3118-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sat, 17 Jun 2017 11:38:05 +0800

> Same as ip_gre, geneve and vxlan, use key->tos as traffic class value.
> 
> CC: Peter Dawson <petedaws@gmail.com>
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
> encapsulated packets”)
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> ---
> Changes since v3:
>   * Add fixes information
>   * Remove obsoleted RT_TOS mask

Applied.
