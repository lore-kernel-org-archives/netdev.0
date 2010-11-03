From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or
	hrtimers crashing
Date: Wed, 3 Nov 2010 08:02:58 +0000
Message-ID: <20101103080258.GB7279@ff.dom.local>
References: <20101028070550.GA7647@ff.dom.local> <201011021549.47466.nuclearcat@nuclearcat.com> <20101103073854.GA7279@ff.dom.local> <201011030947.54464.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Paul Mackerras <paulus@samba.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011030947.54464.nuclearcat@nuclearcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2010 at 09:47:53AM +0200, Denys Fedoryshchenko wrote:
> I try to reverse and got very weird lockups (no netconsole logs and no 
> watchdog triggered reboot on that remote machine).
> I will try to cook something to reboot it, because it is very remote machine

OK, I only wanted to know if reverting could be a fast fix. Since it
isn't, please stay with 2.6.35 until there is some new idea (patch).

Jarek P.
