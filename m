From: Zhang Rui <rui.zhang@intel.com>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Fri, 17 Apr 2009 09:30:13 +0800
Message-ID: <1239931813.7661.394.camel@rzhang-dt>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759399AbZDQBaV@vger.kernel.org>
In-Reply-To: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-04-17 at 05:42 +0800, Rafael J. Wysocki wrote:
> 
> 
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13095
> Subject         : thinkpad-acpi: cannot control brightness with hotkeys
> Submitter       : Niel Lambrechts <niel.lambrechts@gmail.com>
> Date            : 2009-04-11 23:07 (6 days old)
> References      : http://lkml.org/lkml/2009/4/11/160
> Handled-By      : Matthew Garrett <mjg59@srcf.ucam.org>
> Patch           : http://lkml.org/lkml/2009/4/15/339
> 
> 
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13048
> Subject         : /sys/class/backlight/acpi_video0/* is gone on vaio laptop with Intel GM45.
> Submitter       : Rodrigo L. Batista <rodrigo@gus-mg.org>
> Date            : 2009-04-09 04:57 (8 days old)
> Handled-By      : yakui_zhao <yakui.zhao@intel.com>
> Patch           : http://bugzilla.kernel.org/attachment.cgi?id=20967
>                   http://bugzilla.kernel.org/attachment.cgi?id=20959
> 
> 
bug 13095 is a duplicate of bug 13048.
patches from Matthew and Yakui are for the same issue.

Yakui, could you verify which patch should be taken please?

thanks,
rui
