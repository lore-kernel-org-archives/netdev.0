From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: core: let's use native isxdigit instead of
 custom
Date: Wed, 27 Mar 2013 13:09:46 -0400 (EDT)
Message-ID: <20130327.130946.2022129944371817627.davem@davemloft.net>
References: <1364399654-9729-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1364399654-9729-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 27 Mar 2013 17:54:13 +0200

> In kernel we have fast and pretty implementation of the isxdigit() function.
> Let's use it.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
