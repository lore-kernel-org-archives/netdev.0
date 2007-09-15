From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc6: known regressions v2
Date: Sat, 15 Sep 2007 04:29:05 +0200
Message-ID: <46EB4371.307@googlemail.com>
References: <46EB3E94.7080704@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	Dave Kleikamp <shaggy@austin.ibm.com>,
	jfs-discussion@lists.sourceforge.net,
	Andy Whitcroft <apw@shadowen.org>, sct@redhat.com,
	adilger@clusterfs.com, linux-ext4@vger.kernel.org,
	netdev@vger.kernel.org, Shish <shish@shishnet.org>,
	Karl Meyer <adhocrocker@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Daniel Drake <dsd@gentoo.org>,
	Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net,
	Florian Lohoff <flo@rfc822.org>,
	=?ISO-8859-2?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:20414 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760015AbXIOC30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 22:29:26 -0400
Received: by ug-out-1314.google.com with SMTP id z38so589484ugc
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:29:24 -0700 (PDT)
In-Reply-To: <46EB3E94.7080704@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc6.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Andi Kleen                             7
Linus Torvalds                         6
Alan Stern                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
David S. Miller                        4
Al Viro                                3
Alexey Starikovskiy                    3
Cornelia Huck                          3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



=46S

Subject         : hanging ext3 dbench tests
References      : http://lkml.org/lkml/2007/9/11/176
Last known good : ?
Submitter       : Andy Whitcroft <apw@shadowen.org>
Caused-By       : ?
Handled-By      : ?
Status          : under test -- unreproducible at present

Subject         : umount triggers a warning in jfs and takes almost a m=
inute
References      : http://lkml.org/lkml/2007/9/4/73
Last known good : ?
Submitter       : Oliver Neukum <oliver@neukum.org>
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



=46arewell!
Michal

--
LOGOUT
http://www.stardust.webpages.pl/
