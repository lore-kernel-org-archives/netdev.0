From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: test off by one
Date: Sun, 03 Jan 2010 21:43:37 -0800 (PST)
Message-ID: <20100103.214337.226743566.davem@davemloft.net>
References: <4B37D000.6070009@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@users.sourceforge.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753233Ab0ADFnn@vger.kernel.org>
In-Reply-To: <4B37D000.6070009@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 27 Dec 2009 22:22:08 +0100

> With `while (i++ < MII_TIMEOUT)' i reaches MII_TIMEOUT + 1 after the loop
> This is probably unlikely a problem in practice.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
