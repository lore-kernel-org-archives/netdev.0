From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: Add logging message newlines
Date: Sun, 25 Nov 2012 16:15:19 -0500 (EST)
Message-ID: <20121125.161519.2093456773586153692.davem@davemloft.net>
References: <1353756469.6558.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353756469.6558.3.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 24 Nov 2012 03:27:49 -0800

> Avoid any possible message logging interleaving by adding
> missing newlines.
> 
> Align arguments.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
