From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc1: known regressions v3
Date: Mon, 30 Jul 2007 18:33:57 +0200
Message-ID: <46AE12F5.4030706@googlemail.com>
References: <46AE0F5D.3000500@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>,
	Denis Sadykov <denis.m.sadykov@intel.com>, dth <dth@dth.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Thomas Meyer <thomas@m3y3r.de>,
	Florian Lohoff <flo@rfc822.org>,
	=?ISO-8859-2?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	linux-acpi@vger.kernel.org, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@steeleye.com>,
	James Smart <James.Smart@emulex.com>,
	Adrian Bunk <bunk@stusta.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <46AE0F5D.3000500@googlemail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc1.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            6
Andi Kleen                             4
Andrew Morton                          4
Linus Torvalds                         4
Al Viro                                3
Jens Axboe                             3
Tejun Heo                              3
David Woodhouse                        2
Hugh Dickins                           2



CPUFREQ/ACPI

Subject         : ide problems: 2.6.22-git17 working, 2.6.23-rc1* is no=
t
References      : http://lkml.org/lkml/2007/7/27/298
                  http://lkml.org/lkml/2007/7/29/371
Last known good : ?
Submitter       : dth <dth@dth.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : sky2 boot crash in sky2_mac_intr
References      : http://lkml.org/lkml/2007/7/24/91
Last known good : ?
Submitter       : Florian Lohoff <flo@rfc822.org>
Caused-By       :=20
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : unknown

Subject         : New wake ups from sky2
References      : http://lkml.org/lkml/2007/7/20/386
Last known good : ?
Submitter       : Thomas Meyer <thomas@m3y3r.de>
Caused-By       : Stephen Hemminger <shemminger@osdl.org>
                  commit eb35cf60e462491249166182e3e755d3d5d91a28
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : unknown



Power Management

Subject         : New ACPI error/warning with Linus' latest GIT
References      : http://lkml.org/lkml/2007/7/26/395
Last known good : ?
Submitter       : Ismail D=F6nmez <ismail@pardus.org.tr>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



SCSI

Subject         : lpfc_sli.c: off-by-10
References      : http://lkml.org/lkml/2007/7/22/284
Last known good : ?
Submitter       : Adrian Bunk <bunk@stusta.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
-
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
