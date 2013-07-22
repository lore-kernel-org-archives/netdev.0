From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [thermal_init] kernel BUG at net/netlink/genetlink.c:145!
Date: Mon, 22 Jul 2013 17:58:52 +0900 (JST)
Message-ID: <20130722.175852.1830570446481516308.yamato@redhat.com>
References: <20130722083145.GB19067@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eduardo.valentin@ti.com, rui.zhang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130722083145.GB19067@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi Eduardo,
> 
> I got the below dmesg and the first bad commit says that
> thermal_init() is trying to register a too long group name.

It may be related to my mistake.

    http://lists.openwall.net/netdev/2013/03/20/133
    http://lists.openwall.net/netdev/2013/03/21/79

Masatake YAMATO
