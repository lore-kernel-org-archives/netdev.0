From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] Gigabit Ethernet driver of Topcliff PCH
Date: Sun, 26 Sep 2010 23:44:54 -0700 (PDT)
Message-ID: <20100926.234454.241435433.davem@davemloft.net>
References: <4CA03198.8080802@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, john.linn@xilinx.com, ralf@linux-mips.org,
	kristoffer@gaisler.com, mbizon@freebox.fr,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, okada533@dsn.okisemi.com,
	shimizu394@dsn.okisemi.com, morinaga526@dsn.okisemi.com,
	qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	margie.foster@intel.com, meego-dev@meego.com
To: masa-korg@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA03198.8080802@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Date: Mon, 27 Sep 2010 14:54:32 +0900

> Gigabit Ethernet driver of Topcliff PCH
> 
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus. 
> Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to 
> access system devices connected to Gigabit Ethernet.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

I already added your driver to my net-next-2.6 tree, why are
you sending this again? :-(
