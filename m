From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/4] 2.6.23-rc6: known regressions
Date: Wed, 12 Sep 2007 18:59:00 +0200
Message-ID: <46E81AD4.8000906@googlemail.com>
References: <46E8187E.9000006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux1394-devel@lists.sourceforge.net,
	Ben Collins <ben.collins@ubuntu.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Pavel Machek <pavel@ucw.cz>, netdev@vger.kernel.org,
	Shish <shish@shishnet.org>, Karl Meyer <adhocrocker@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Daniel Drake <dsd@gentoo.org>,
	Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net,
	Florian Lohoff <flo@rfc822.org>,
	=?ISO-8859-2?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:9741 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934812AbXILQ7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 12:59:51 -0400
Received: by fk-out-0910.google.com with SMTP id z23so230559fkz
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 09:59:50 -0700 (PDT)
In-Reply-To: <46E8187E.9000006@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc6.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Linus Torvalds                         6
Alan Stern                             5
Andi Kleen                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
Al Viro                                3
Alexey Starikovskiy                    3
Cornelia Huck                          3
David S. Miller                        3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



=46ireWire

Subject         : empty suspend stopped working around 2.6.23-rc4
References      : http://lkml.org/lkml/2007/9/11/326
Last known good : ?
Submitter       : Pavel Machek <pavel@ucw.cz>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : build #301 failed for 2.6.23-rc6-g0d4cbb5 in linux/dr=
ivers/net/wireless/libertas/
References      : http://lkml.org/lkml/2007/9/11/150
Last known good : ?
Submitter       : Toralf F=F6rster <toralf.foerster@gmx.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : zd1211rw regression, device does not enumerate
References      : http://marc.info/?l=3Dlinux-usb-devel&m=3D11885496770=
9322&w=3D2
                  http://bugzilla.kernel.org/show_bug.cgi?id=3D8972
Last known good : ?
Submitter       : Oliver Neukum <oliver@neukum.org>
Caused-By       : Daniel Drake <dsd@gentoo.org>
                  commit 74553aedd46b3a2cae986f909cf2a3f99369decc
Handled-By      : ?
Status          : unknown

Subject         : NETDEV WATCHDOG: eth0: transmit timed out
References      : http://lkml.org/lkml/2007/8/13/737
Last known good : ?
Submitter       : Karl Meyer <adhocrocker@gmail.com>
Caused-By       : ?
Handled-By      : Francois Romieu <romieu@fr.zoreil.com>
Status          : problem is being debugged

Subject         : Weird network problems with 2.6.23-rc2
References      : http://lkml.org/lkml/2007/8/11/40
Last known good : ?
Submitter       : Shish <shish@shishnet.org>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
