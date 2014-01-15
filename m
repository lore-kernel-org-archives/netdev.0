From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [trivial] ixgbe: Fix format string in ixgbe_fcoe.c
Date: Wed, 15 Jan 2014 14:55:47 -0800 (PST)
Message-ID: <20140115.145547.1868806980328924895.davem@davemloft.net>
References: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: standby24x7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389716082-23395-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Wed, 15 Jan 2014 01:14:42 +0900

> cppcheck detected following warning in ixgbe_fcoe.c
> (warning) %d in format string (no. 1) requires 'int' but the
> argument type is 'unsigned int'.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Intel folks, please be sure to pick this up.
