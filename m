From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc1: known regressions v2
Date: Fri, 27 Jul 2007 22:53:13 +0200
Message-ID: <46AA5B39.2010209@googlemail.com>
References: <46AA581D.6080100@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Sesterhenn <snakebyte@gmx.de>,
	Sid Boyce <g3vbv@blueyonder.co.uk>, linux-ide@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	dth <dth@dth.net>, Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Thomas Meyer <thomas@m3y3r.de>, Florian Lohoff <flo@rfc822.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:19649 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936168AbXG0U4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 16:56:02 -0400
Received: by ug-out-1314.google.com with SMTP id j3so770793ugf
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2007 13:56:01 -0700 (PDT)
In-Reply-To: <46AA581D.6080100@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc1.

Feel free to add new regressions/remove fixed etc.
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



Unclassified

Subject         : 2.6.23-rc1-git3 init failure
References      : http://lkml.org/lkml/2007/7/26/467
Last known good : ?
Submitter       : Sid Boyce <g3vbv@blueyonder.co.uk>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : Time Problems with 2.6.23-rc1-gf695baf2
References      : http://lkml.org/lkml/2007/7/23/486
Last known good : ?
Submitter       : Eric Sesterhenn <snakebyte@gmx.de>
Caused-By       : ?
Handled-By      : ?
Status          : problem is being debugged



IDE

Subject         : ide problems: 2.6.22-git17 working, 2.6.23-rc1* is not
References      : http://lkml.org/lkml/2007/7/27/298
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



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
