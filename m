From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch netdev-2.6 0/2] r8169: vlan hwaccel fixes
Date: Fri, 22 Oct 2004 21:51:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023015111.GC32031@tuxdriver.com>
References: <20041022005737.GA1945@tuxdriver.com> <20041022202851.GB4216@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041022202851.GB4216@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 10:28:51PM +0200, Francois Romieu wrote:
> John W. Linville <linville@tuxdriver.com> :
> > Patch 2:
> [nice explanation]
> 
> Any objection against me replacing the actual comment of patch #2 (i.e.
> "why" instead of "how") and splitting the "if ((tp->>vlgrp = grp))" over
> two lines ?

Not quite sure which comment you mean, but I'm sure that's fine.
I posted a third patch to fix-up that tricky if() -- you're right,
it is a little TOO clever... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
