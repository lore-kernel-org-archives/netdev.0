From: James Bottomley <James.Bottomley@SteelEye.com>
Subject: Re: [PATCH 20/59] sysctl: cdrom Don't set de->owner
Date: Tue, 16 Jan 2007 12:19:34 -0600
Message-ID: <1168971574.2789.14.camel@mulgrave.il.steeleye.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
	 <11689656373737-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "<Andrew Morton" <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	containers@lists.osdl.org, netdev@vger.kernel.org,
	xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
	linux-scsi@vger.kernel.org, minyard@acm.org,
	openipmi-developer@lists.sourceforge.net, tony.luck@intel.com,
	linux-mips@linux-mips.org, ralf@linux-mips.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	linux390@de.ibm.com, linux-390@vm.marist.edu, paulus@samba.org,
	linuxppc-dev@ozlabs.org, lethal@linux-sh.org,
	linuxsh-shmedia-dev@lists.sourceforge.net, ak@suse.de,
	vojtech@suse.cz, clemens@ladisch.de, a.zummo@towertech.it,
	rtc-linux@googlegroups.com, linux-parport@lists.infradead.org,
	andrea@suse.de, tim@cyberelk.net, philb@gnu.org,
	aharkes@cs.cmu.edu, coda@cs.cmu.edu,
	codalist@TELEMANN.coda.cs.cmu.edu, aia21@cantab.net,
	linux-ntfs-dev@lists.sourceforge.net, mark.fasheh@oracle.com,
	kurt.hackel@oracle.com
Return-path: <linux-scsi-owner@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <11689656373737-git-send-email-ebiederm@xmission.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-16 at 09:39 -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

These three look OK:

[PATCH 15/59] sysctl: scsi remove unnecessary insert_at_head flag
[PATCH 19/59] sysctl: cdrom remove unnecessary insert_at_head flag
[PATCH 20/59] sysctl: cdrom Don't set de->owner

So you can add an ACK from me.

It would have been nice not to have 56 other irrelevant patches sprayed
over the list and into my inbox, though ...

James


