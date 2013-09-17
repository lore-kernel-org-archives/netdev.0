From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] drivers: net: phy: cicada.c: clears warning Use
 #include <linux/io.h> instead of <asm/io.h>
Date: Tue, 17 Sep 2013 19:07:15 -0400 (EDT)
Message-ID: <20130917.190715.1868248025150913908.davem@davemloft.net>
References: <1379347781-7145-1-git-send-email-avi.kp.137@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: avi.kp.137@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379347781-7145-1-git-send-email-avi.kp.137@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avinash Kumar <avi.kp.137@gmail.com>
Date: Mon, 16 Sep 2013 21:39:41 +0530

> clears following warnings :
> WARNING: Use include <linux/io.h> instead of <asm/io.h>
> WARNING: Use include <linux/uaccess.h> instead of <asm/uaccess.h>
> 
> Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>

Applied, thanks.
