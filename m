From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 2.6.9-rc4-mm1] [m32r] Fix smc91x driver for m32r
Date: Thu, 14 Oct 2004 09:46:57 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.61.0410140946340.17226@xanadu.home>
References: <416BFD79.1010306@pobox.com> <20041013.105243.511706221.takata.hirokazu@renesas.com>
 <416C8E0B.4030409@pobox.com> <20041013.121547.863739114.takata.hirokazu@renesas.com>
 <20041012223227.45a62301.akpm@osdl.org> <20041014113044.A5076@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>,
	Hirokazu Takata <takata.hirokazu@renesas.com>,
	jgarzik@pobox.com, takata@linux-m32r.org,
	linux-kernel@vger.kernel.org, paul.mundt@nokia.com,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S264980AbUJNNrc@vger.kernel.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20041014113044.A5076@flint.arm.linux.org.uk>
List-Id: netdev.vger.kernel.org

On Thu, 14 Oct 2004, Russell King wrote:

> On Tue, Oct 12, 2004 at 10:32:27PM -0700, Andrew Morton wrote:
> > smc91x-assorted-minor-cleanups.patch
> 
> This patch removes a comment I added to satisfy Jeff's review which
> explains how the link state is initialised - it probably isn't a good
> idea to remove this.

It was just moved elsewhere.


Nicolas
