From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/14] RDS: connection scalability and performance
 improvements
Date: Wed, 07 Oct 2015 02:16:34 -0700 (PDT)
Message-ID: <20151007.021634.1127057852275250731.davem@davemloft.net>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Mon,  5 Oct 2015 10:56:23 -0700

> [v3]
> Updated patch "[PATCH v2 05/14] RDS: defer the over_batch work to
> send worker" as per David Miller's comment [4] to avoid the magic
> value usage. Patch now makes use of already available but unused
> send_batch_count module parameter. Rest of the patches are same as
> earlier version v2 [3]

Can you respin this again?  Your repost of patch 05/14 was severely whitespace
damaged.
