From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V11 0/4] ptp: IEEE 1588 hardware clock support
Date: Wed, 23 Feb 2011 11:50:07 +0100
Message-ID: <20110223105007.GA31292@riccoc20.at.omicron.at>
References: <cover.1298447722.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
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
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1298447722.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Previous Discussions

  This patch set previously appeared on the netdev list. Since V5 of
  the character device patch set, the discussion has moved to the
  lkml.

  - IEEE 1588 hardware clock support [V5]
    http://lkml.org/lkml/2010/8/16/90

  - POSIX clock tuning syscall with static clock ids
    http://lkml.org/lkml/2010/8/23/49

  - POSIX clock tuning syscall with dynamic clock ids
    http://lkml.org/lkml/2010/9/3/119

  - IEEE 1588 hardware clock support [V6]
    http://lkml.org/lkml/2010/9/23/310

  - Dynamic clock devices [RFC]
    http://lkml.org/lkml/2010/11/4/290

  - IEEE 1588 hardware clock support [V7]
    http://lkml.org/lkml/2010/12/16/195

  - IEEE 1588 hardware clock support [V8]
    http://lkml.org/lkml/2010/12/31/128

  - IEEE 1588 hardware clock support [V9]
    http://lkml.org/lkml/2011/1/13/65

  - IEEE 1588 hardware clock support [V10]
    http://lkml.org/lkml/2011/1/27/71

  - Thomas Gleixner: Rework of the PTP support series core code
    http://lkml.org/lkml/2011/2/1/137
