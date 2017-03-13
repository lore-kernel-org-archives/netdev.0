From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: tun: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 15:26:22 -0700 (PDT)
Message-ID: <20170313.152622.19911980717573056.davem@davemloft.net>
References: <1489266230-2282-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, edumazet@google.com,
        pabeni@redhat.com, fgao@ikuai8.com, elfring@users.sourceforge.net,
        jarno@ovn.org, rppt@linux.vnet.ibm.com, jarod@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489266230-2282-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 11 Mar 2017 22:03:50 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - Finaly, I've found the hardware and do basic test ;)
>   thanks Michael S. Tsirkin and Eric Dumazet for the feedback

:-)  Applied.
