From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 3.0-rc6-git6: Reported regressions from 2.6.39
Date: Sun, 10 Jul 2011 13:12:27 +0200
Message-ID: <201107101312.27466.rjw@sisk.pl>
References: <Y7LyOsOBwFM.A.kJG.kBYGOB@chimera> <1310295277.3942.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1310295277.3942.1.camel@jlt3.sipsolutions.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, July 10, 2011, Johannes Berg wrote:
> On Sun, 2011-07-10 at 12:19 +0200, Rafael J. Wysocki wrote:
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38702
> > Subject		: 3.0.0-rc4-git6 - INFO: possible circular locking dependency detected - (&rdev->mtx){+.+.+.}, at: [<ffffffffa00e27e0>] cfg80211_netdev_notifier_call+0x275/0x4ff [cfg80211]
> > Submitter	: Miles Lane <miles.lane@gmail.com>
> > Date		: 2011-06-26 21:54 (15 days old)
> > Message-ID	: <BANLkTikztsFnPkJZ7VxRC-zsitwCCvVmeg@mail.gmail.com>
> > References	: http://marc.info/?l=linux-kernel&m=130912559804336&w=2
> 
> Should be fixed by c10841ca722a0bc960dc541c51582773f9a24f98 which was
> part of John's latest pull request and is in net-2.6 now on its way up.

Thanks, closing.

Rafael
