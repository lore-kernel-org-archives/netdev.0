From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Mon, 26 Mar 2012 19:12:37 -0400 (EDT)
Message-ID: <20120326.191237.2192763107267474232.davem@davemloft.net>
References: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
	<1332800304-5060-2-git-send-email-haiyangz@microsoft.com>
	<20120326231017.GA30684@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de,
	linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120326231017.GA30684@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 26 Mar 2012 16:10:17 -0700

> David, please do NOT apply this as-is.

BTW, ethtool had controls exactly for stuff like this.
