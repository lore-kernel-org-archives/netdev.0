From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Mon, 27 Sep 2010 10:56:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009271054320.9258@router.home>
References: <cover.1285261533.git.richard.cochran@omicron.at> <20100923213654.0c64b047@lxorguk.ukuu.org.uk> <20100924131407.GA3113@riccoc20.at.omicron.at> <20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 24 Sep 2010, Alan Cox wrote:

> Whether you add new syscalls or do the fd passing using flags and hide
> the ugly bits in glibc is another question.

Use device specific ioctls instead of syscalls?
