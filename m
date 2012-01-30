From: Greg KH <gregkh@suse.de>
Subject: Re: [02/22] Cyclades PC300 driver: re-enable Kconfig option
Date: Mon, 30 Jan 2012 06:33:59 -0800
Message-ID: <20120130143359.GA13388@suse.de>
References: <20120130024446.GC10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	alan@linux.intel.com, jdmason@kudzu.us
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120130024446.GC10262@cronus.persephoneslair.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 29, 2012 at 06:44:46PM -0800, Andrea Shepard wrote:
> The old pc300 driver had been disabled because it did not build.  This patch
> re-enables it in Kconfig.

But isn't the build still broken at this point in time?
