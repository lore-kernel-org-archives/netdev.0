From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V14 4/4] ptp: Added a clock driver for the National
 Semiconductor PHYTER.
Date: Fri, 22 Apr 2011 11:21:59 +0200
Message-ID: <20110422092159.GA18708@riccoc20.at.omicron.at>
References: <cover.1303107532.git.richard.cochran@omicron.at>
 <1728ffb5735c2a04876a69ad55427c4e7b5a1bd7.1303107532.git.richard.cochran@omicron.at>
 <1303160245.2857.60.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@arm.linux.org.uk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1303160245.2857.60.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2011 at 09:57:25PM +0100, Ben Hutchings wrote:
> Would be better without the magic numbers.

Yes, of course, you are right, and also about patch #3.
Please take a look at v15 and see if it improves things.

Thanks,

Richard
