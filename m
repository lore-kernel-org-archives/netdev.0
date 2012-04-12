From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: simple_strtoul cleanup
Date: Thu, 12 Apr 2012 16:09:24 -0400 (EDT)
Message-ID: <20120412.160924.1955339981542902073.davem@davemloft.net>
References: <1334258893.3022.7.camel@lorien2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shuahkhan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334258893.3022.7.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuahkhan@gmail.com>
Date: Thu, 12 Apr 2012 13:28:13 -0600

> Changed net/core/net-sysfs.c: netdev_store() to use kstrtoul() 
> instead of obsolete simple_strtoul().
> 
>>From 84371b0ed8b277ec8005fd0efbc73165a8bd72b9 Mon Sep 17 00:00:00 2001
> From: Shuah Khan <shuahkhan@gmail.com>
> Date: Thu, 12 Apr 2012 10:36:10 -0600
> Subject: [PATCH] net/core: simple_strtoul cleanup
> 
> 
> Signed-off-by: Shuah Khan <shuahkhan@gmail.com>

Applied, thanks.
