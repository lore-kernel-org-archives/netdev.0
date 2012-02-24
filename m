From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] print MAC via printk format specifier
Date: Fri, 24 Feb 2012 15:42:24 -0500 (EST)
Message-ID: <20120224.154224.992364563810018486.davem@davemloft.net>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, grant.likely@secretlab.ca, oneukum@suse.de,
	linux-usb@vger.kernel.org, linux-ia64@vger.kernel.org,
	grundler@parisc-linux.org, jkosina@suse.cz,
	e1000-devel@lists.sourceforge.net, gregkh@linuxfoundation.org,
	jpirko@redhat.com, dkukawka@suse.de,
	linux-kernel@vger.kernel.org, pe1dnn@amsat.org,
	netdev@vger.kernel.org, geert@linux-m68k.org, kernel@wantstofly.org
To: danny.kukawka@bisect.de
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Fri, 24 Feb 2012 14:45:51 +0100

> Print MAC/dev_addr via printk extended format specifier %pm/%pM
> instead of using custom code.
> 
> These patches are against net-next.

All applied, but you absolutely have to start posting patch series
correctly.

If it's a series for net-next, then every single patch must be
CC:'d to netdev so it gets queued up properly in patchwork.
