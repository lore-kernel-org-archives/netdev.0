From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 2.6.9-rc4-mm1] [m32r] Fix smc91x driver for m32r
Date: Thu, 14 Oct 2004 11:30:44 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041014113044.A5076@flint.arm.linux.org.uk>
References: <416BFD79.1010306@pobox.com> <20041013.105243.511706221.takata.hirokazu@renesas.com> <416C8E0B.4030409@pobox.com> <20041013.121547.863739114.takata.hirokazu@renesas.com> <20041012223227.45a62301.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hirokazu Takata <takata.hirokazu@renesas.com>, jgarzik@pobox.com,
	takata@linux-m32r.org, linux-kernel@vger.kernel.org,
	paul.mundt@nokia.com, nico@cam.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S270023AbUJNKbA@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041012223227.45a62301.akpm@osdl.org>; from akpm@osdl.org on Tue, Oct 12, 2004 at 10:32:27PM -0700
List-Id: netdev.vger.kernel.org

On Tue, Oct 12, 2004 at 10:32:27PM -0700, Andrew Morton wrote:
> smc91x-assorted-minor-cleanups.patch

This patch removes a comment I added to satisfy Jeff's review which
explains how the link state is initialised - it probably isn't a good
idea to remove this.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
