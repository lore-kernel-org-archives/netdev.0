From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc2: known regressions
Date: Sun, 05 Aug 2007 18:26:26 +0200
Message-ID: <46B5FA32.50208@googlemail.com>
References: <46B5F74D.7010708@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Andrew Clayton <andrew@digital-domain.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Thomas Meyer <thomas@m3y3r.de>,
	Florian Lohoff <flo@rfc822.org>, Uwe Bugla <uwe.bugla@gmx.de>,
	linux-pm@lists.linux-foundation.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	Meelis Roos <mroos@linux.ee>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:26560 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756824AbXHEQ1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2007 12:27:39 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1215311fkz
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2007 09:27:37 -0700 (PDT)
In-Reply-To: <46B5F74D.7010708@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc2.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            6
Andi Kleen                             4
Andrew Morton                          4
Linus Torvalds                         4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3
David Woodhouse                        2
Hugh Dickins                           2
Trent Piepho                           2



FS

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : IP v4 routing is broken
References      : http://www.stardust.webpages.pl/files/tbf/bugs/bug_report01.txt
Last known good : 2.6.22-git2
Submitter       : Uwe Bugla <uwe.bugla@gmx.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : sky2 boot crash in sky2_mac_intr
References      : http://lkml.org/lkml/2007/7/24/91
Last known good : ?
Submitter       : Florian Lohoff <flo@rfc822.org>
Caused-By       : 
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



Power management

Subject         : Kconfig: 'SUSPEND_SMP' refers to undefined symbol 'HOTPLUG_CPU'
References      : http://lkml.org/lkml/2007/8/4/39
Last known good : ?
Submitter       : Meelis Roos <mroos@linux.ee>
Caused-By       : ?
Handled-By      : Rafael J. Wysocki <rjw@sisk.pl>
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
