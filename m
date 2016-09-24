From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] BQL support and fix for a regression issue
Date: Sat, 24 Sep 2016 08:47:40 -0400 (EDT)
Message-ID: <20160924.084740.220729213459690389.davem@davemloft.net>
References: <1474621948-9172-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474621948-9172-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Fri, 23 Sep 2016 14:42:26 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> These patches add byte queue limit support and also fixes a regression
> issue introduced by commit
> 'net: thunderx: Use netdev's name for naming VF's interrupts'
> 
> Changes from v1:
> - As suggested added 'Fixes' tag with commit id of previous commit 
>   which cuased issue.
> - Also fixed the missing netdev_tx_reset_queue() function call in 
>   byte queue limits support patch.

Series applied to net-next, thanks.
