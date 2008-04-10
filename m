From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SCTP: fix wrong debug counting of bind_bucket
Date: Thu, 10 Apr 2008 01:58:17 -0700 (PDT)
Message-ID: <20080410.015817.30312170.davem@davemloft.net>
References: <47F1AF14.2040600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lizf@cn.fujitsu.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756635AbYDJI63@vger.kernel.org>
In-Reply-To: <47F1AF14.2040600@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 01 Apr 2008 11:42:12 +0800

> Should not count it if the allocation of the object
> is failed.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Also applied to net-2.6.26, thanks.
