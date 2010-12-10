From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-12-10
Date: Fri, 10 Dec 2010 12:52:52 -0800 (PST)
Message-ID: <20101210.125252.212677124.davem@davemloft.net>
References: <20101210202902.GG4296@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101210202902.GG4296@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 10 Dec 2010 15:29:03 -0500

> Here is the latest round of wireless bits intended for 2.6.37...
> 
> Included are some orinoco fixes, one to avoid the crash in bug 23932 and
> two others that render TKIP countermeasures ineffective (i.e. decreased
> security).  Helmut has provided us a fix to avoid a BUG when using
> shared skbs.  The ath9k team gives us a fix for failed resumes on
> ath9k_htc, a fix for detecting broadcast frames with a MIC failure, a
> fix for a null pointer access when generating beacons, and a DMA issue
> that can lead to memory corruption.  Matteo Croce pitches-in with a fix
> to prevent transmitting with too much power.  Finally,  Javier Cardona
> provides a trio of ath5k fixes that restore mesh function on those
> devices.
> 
> Please let me know if there are problems!

Pulled, thanks John.
