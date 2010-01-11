From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: 2.6.33-rc3-git3: Reported regressions from 2.6.32
Date: Mon, 11 Jan 2010 16:47:10 -0500
Message-ID: <20100111214603.GA4335@emergent.ellipticsemi.com>
References: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752562Ab0AKVsk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <wnS54-l8PVO.A.TlF.oMlSLB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23:27 Sun 10 Jan     , Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 2.6.32, for which there
> are no fixes in the mainline I know of.  If any of them have been fixed already,
> please let me know.
> 
> If you know of any other unresolved regressions from 2.6.32, please let me know
> either and I'll add them to the list.  Also, please let me know if any of the
> entries below are invalid.

Here are two that I don't see in the list:

 * LVDS downclocking breaks on G45/thinkpad T500

     LKML: http://lkml.org/lkml/2009/12/26/40
     FDO:  http://bugs.freedesktop.org/show_bug.cgi?id=25809
 
 * Receive failure in et131x (Alan Cox sent me a patch for this but
                              it's not in mainline yet)

     LKML: http://lkml.org/lkml/2009/12/29/210

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
