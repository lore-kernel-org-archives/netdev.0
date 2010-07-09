From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 9 Jul 2010 02:16:57 +0200
Message-ID: <AANLkTimmGRikJAWmVeYRkvr9-3AoeO9APN-oDlCJUpvl@mail.gmail.com>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafael,

On Fri, Jul 9, 2010 at 1:33 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
[...]
Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=16169
Subject         : Complain from preemptive debug
Submitter       : Sedat Dilek <sedat.dilek@googlemail.com>
Date            : 2010-05-31 10:10 (39 days old)
Message-ID      : <AANLkTilTnAAZIizKinYsxFkNTkrmPqk6XJJuUjjhJ7EP@mail.gmail.com>
References      : http://lkml.org/lkml/2010/5/31/77
Handled-By      : Dmitry Monakhov <dmonakhov@openvz.org>
                 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Patch           : http://www.spinics.net/lists/cpufreq/msg01631.html
                 https://patchwork.kernel.org/patch/106555/

This bug is fixed Upstream [1]:

commit 8c215bd3890c347dfb6a2db4779755f8b9c298a9
"sched: Cure nr_iowait_cpu() users"

- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=8c215bd3890c347dfb6a2db4779755f8b9c298a9
