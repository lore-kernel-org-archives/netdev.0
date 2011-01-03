From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 7/8] ptp: Added a clock driver for the IXP46x.
Date: Mon, 3 Jan 2011 18:07:34 +0100
Message-ID: <20110103170732.GA3700@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <d2e0a5ac5eb51e9e4c7fcc94723b67c72c2f57c1.1292512461.git.richard.cochran@omicron.at>
 <20110102084505.GA3980@ucw.cz>
 <20110102091233.GA2847@riccoc20.at.omicron.at>
 <20110102092042.GA14165@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110102092042.GA14165@ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 02, 2011 at 10:20:42AM +0100, Pavel Machek wrote:
> Given the comments -- does manual really use camelCase crap?
> And... the identifiers actually combine camelCase with _. Better fix
> it.

Thats the way Intel likes it:

http://download.intel.com/design/network/manuals/30626204.pdf

Page 837
