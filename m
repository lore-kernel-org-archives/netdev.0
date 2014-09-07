From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rose: use %*ph specifier
Date: Sun, 07 Sep 2014 16:07:45 -0700 (PDT)
Message-ID: <20140907.160745.1390919200676816134.davem@davemloft.net>
References: <1409931138-25447-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1409931138-25447-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri,  5 Sep 2014 18:32:18 +0300

> Instead of dereference each byte let's use %*ph specifier in the printk()
> calls.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
