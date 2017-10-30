From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Set tx_table to equal weight after
 subchannels open
Date: Mon, 30 Oct 2017 09:43:10 +0900 (KST)
Message-ID: <20171030.094310.1672506568658014584.davem@davemloft.net>
References: <MWHPR21MB0479A6CB81170F0EA4442661CA580@MWHPR21MB0479.namprd21.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <MWHPR21MB0479A6CB81170F0EA4442661CA580@MWHPR21MB0479.namprd21.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Sun, 29 Oct 2017 20:38:59 +0000

> Could you please also queue it for net 4.14 and stable?

This is not how you are supposed to handle things.

When you have a bug fix you submit the fix for 'net' and
then ask for it to be queued up for -stable.

And then it will automatically eventually appear in 'net-next' as
well.

Please don't handle things the way you did in the future.

Thank you.
