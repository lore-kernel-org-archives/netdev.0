From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH v3 0/2] net/macb: merge at91_ether driver into macb
 driver
Date: Sat, 7 Mar 2015 07:32:34 +0100
Message-ID: <20150307073234.14df134a@bbrezillon>
References: <1425638921-9768-1-git-send-email-boris.brezillon@free-electrons.com>
	<20150306.151830.2271015374667204230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.ferre@atmel.com,
	plagnioj@jcrosoft.com, alexandre.belloni@free-electrons.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150306.151830.2271015374667204230.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

On Fri, 06 Mar 2015 15:18:30 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Boris Brezillon <boris.brezillon@free-electrons.com>
> Date: Fri,  6 Mar 2015 11:48:39 +0100
> 
> > Changes since v2:
> > - rebase after changed brought by [1]
> 
> Ugh, actually I'm tossing all of your changes.  Please do not make
> complex dependencies like this.

Okay, I'll remember that next time I submit patches to netdev.

I've sent a new series integrating the patch this series depends on.

Let me know if there's something wrong in this one.

> 
> And furthermore, don't reference other sets of changes via lkml
> postings.  Reference them by where they are in patchwork which is
> the definitive location for networking patch submissions.

Noted.

Best Regards,

Boris

-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
