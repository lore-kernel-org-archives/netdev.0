From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net/hyperv: Convert camel cased variables in
 rndis_filter.c to lower cases
Date: Wed, 01 Feb 2012 14:36:55 -0500 (EST)
Message-ID: <20120201.143655.1013171439305457146.davem@davemloft.net>
References: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327941218-12547-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please do not mix cleanups with real bug fixes.

Patches #4 and #5 in this series fix real bugs, so you should submit them
seperately for inclusion to my 'net' tree.

Once those fixes have propagated to my 'net-next' tree, you can then submit
the cleanups.
