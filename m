From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: 2.6.15-rc7: known regressions
Date: Mon, 2 Jan 2006 10:57:58 -0800
Message-ID: <20060102185757.GA11648@us.ibm.com>
References: <Pine.LNX.4.64.0512241930370.14098@g5.osdl.org> <20060102164636.GH17398@stusta.de>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kirill Korotaev <dev@sw.ru>,
	Ismail Donmez <ismail@uludag.org.tr>,
	Michael Madore <michael.madore@gmail.com>,
	David Brownell <david-b@pacbell.net>,
	Wu Fengguang <wfg@mail.ustc.edu.cn>,
	Mathias Klein <ma_klein@gmx.de>,
	Christian Casteyde <casteyde.christian@free.fr>,
	"P. Christeas" <p_christ@hol.gr>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Torsten Seeboth <Torsten.Seeboth@t-online.de>, pj@sgi.com,
	simon.derr@bull.net, jt@hpl.hp.com, netdev@vger.kernel.org,
	Andrey Borzenkov <arvidjaar@mail.ru>, gregkh@suse.de,
	linux-usb-devel@lists.sourceforge.net, phil.el@wanadoo.fr,
	oprofile-list@lists.sourceforge.net, perex@suse.cz,
	alsa-devel@alsa-project.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750964AbWABS6f@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060102164636.GH17398@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 02, 2006 at 05:46:36PM +0100, Adrian Bunk wrote:
> This email lists some known regressions in 2.6.15-rc7 compared to 2.6.14.
> 
> If you find your name in the Cc header, you are either submitter of one 
> of the bugs, maintainer of an affectected subsystem or driver, a patch 
> of you was declared guilty for a breakage or in any other way involved 
> with one or more of these issues.

[ . . . ]

> Subject    : BUG: spinlock recursion on 2.6.14-mm2 when oprofiling
> References : http://lkml.org/lkml/2005/11/18/95
> Submitter  : Wu Fengguang <wfg@mail.ustc.edu.cn>
> Handled-By : "Paul E. McKenney" <paulmck@us.ibm.com>
> Status     : unknown, reported against -mm, already fixed in -mm
>              (make-rcu-task_struct-safe-for-oprofile.patch)
>              Is this bug present in Linus' tree?

No, this bug is not present in Linus's tree.

							Thanx, Paul
