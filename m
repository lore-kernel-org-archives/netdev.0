From: Andi Kleen <andi@firstfloor.org>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Wed, 21 Feb 2007 12:34:09 +0100
Message-ID: <20070221113409.GA28479@one.firstfloor.org>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220170232.GA4730@outpost.ds9a.nl> <20070220171120.GD24930@2ka.mipt.ru> <20070221110634.GA30394@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932421AbXBULeY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070221110634.GA30394@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 02:06:34PM +0300, Evgeniy Polyakov wrote:
> Here is data for 50 bytes reading for essentially idle machine 
> (core duo 2.4 ghz):
> 
> delta for syscall: 3326961404-3326969261: 7857 cycles = 3.273750 us

Can you oprofile it too?

-Andi
