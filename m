From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] netconsole: Add tty driver
Date: Tue, 01 Apr 2014 17:36:39 -0400 (EDT)
Message-ID: <20140401.173639.1201135615627128904.davem@davemloft.net>
References: <CAOte+=Y5bSq96wXUHQnAZQRn4jMf+6V5Py6nU3eLNEW9NaRzzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	schwab@linux-m68k.org, netdev@vger.kernel.org, nikolay@redhat.com,
	andy.shevchenko@gmail.com, gregkh@linuxfoundation.org,
	jiri@resnulli.us, joe@perches.com, alonid@postram.com
To: struan.bartlett@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOte+=Y5bSq96wXUHQnAZQRn4jMf+6V5Py6nU3eLNEW9NaRzzg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Struan Bartlett <struan.bartlett@gmail.com>
Date: Tue, 1 Apr 2014 23:13:06 +0200

> Adds tty driver to netconsole module. When module is loaded, it
> creates /dev/netcon0 device and enables support for console=netcon0
> kernel cmdline option, causing /dev/console output to be sent to
> /dev/netcon0. This allows startup/shutdown script output from
> headless platforms to be logged over (secure) network.
> 
> Signed-off-by: Struan Bartlett <struan.bartlett@gmail.com>

Your patch was severely corrupted by your email client, making
your patch unusuable to us.

Please read Documentation/email-clients.txt
