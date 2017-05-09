From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: wimax: i2400m: i2400m-usb: Use
 time_after for time comparison
Date: Tue, 09 May 2017 09:40:46 -0400 (EDT)
Message-ID: <20170509.094046.795668836609742751.davem@davemloft.net>
References: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
        <1494288410-19028-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: karim.eshapa@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494288410-19028-1-git-send-email-karim.eshapa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karim Eshapa <karim.eshapa@gmail.com>
Date: Tue,  9 May 2017 02:06:50 +0200

> Use time_after() for time comparison with the new fix.
> 
> Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>

This looks a lot better, applied, thanks.
