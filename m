From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH -stable] Add USB PID for new MOSCHIP USB ethernet
 controller MCS7832 variant
Date: Tue, 30 Nov 2010 12:27:12 -0800
Message-ID: <20101130202712.GB16171@suse.de>
References: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, stable@kernel.org,
	Arnd Bergmann <arnd@arndb.de>, dhollis@davehollis.com,
	Phil Chang <pchang23@sbcglobal.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101130200737.GA5185@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2010 at 09:07:37PM +0100, Andreas Mohr wrote:
> Due to active notification of the new MCS7832 version by the manufacturer
> today (Mr. Milton; thanks!) -- quote: "functionality same as MCS7830",
> I'm now submitting this patch, intended for networking.git and -stable.

This is not how you get stuff into the stable kernel trees, sorry.
Please read Documentation/stable_kernel_rules.txt for how to do that.

Sometimes I wonder why we even write documentation if no one ever reads
it...

thanks,

greg k-h
