From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add devm version of alloc_etherdev_mqs
 function
Date: Sun, 29 Jan 2017 19:24:34 -0500 (EST)
Message-ID: <20170129.192434.339228303342526617.davem@davemloft.net>
References: <20170128141542.9676-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: pablo@netfilter.org, andrew@lunn.ch, joe@perches.com,
        tom@herbertland.com, aduyck@mirantis.com, brouer@redhat.com,
        jarod@redhat.com, sd@queasysnail.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170128141542.9676-1-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Sat, 28 Jan 2017 15:15:42 +0100

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> This patch adds devm_alloc_etherdev_mqs function and devm_alloc_etherdev
> macro. These can be used for simpler netdev allocation without having to
> care about calling free_netdev.
> 
> Thanks to this change drivers, their error paths and removal paths may
> get simpler by a bit.
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>

This looks fine, thanks.
