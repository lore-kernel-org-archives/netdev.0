From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Thu, 23 Jan 2014 13:39:48 -0800 (PST)
Message-ID: <20140123.133948.1912867106975845377.davem@davemloft.net>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
	<20140122.175031.873909526743971037.davem@davemloft.net>
	<52E11563.1090707@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E11563.1090707@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 23 Jan 2014 13:13:07 +0000

> It is already based on two predecessor patches, one which is already
> accepted but not applied yet:
> 
> [PATCH net-next v2] xen-netback: Rework rx_work_todo
> 
> And the other one is hopefully will be accepted very soon:
> 
> [PATCH v5] xen/grant-table: Avoid m2p_override during mapping

These have both been asked for changes or small adjustments to be made.

Also, you really have to precisely and explicitly mention any
dependencies which exist.

In fact, it's often best to not post a series until the dependent
patches have been accepted.
