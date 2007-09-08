From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/2] 2.6.23-rc5: known regressions with patches v2
Date: Sat, 08 Sep 2007 13:11:39 +0200
Message-ID: <46E2836B.60406@googlemail.com>
References: <46E28149.2090900@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Pierre Ossman <drzeus-mmc@drzeus.cx>,
	Christian Casteyde <casteyde.christian@free.fr>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	Florian Lohoff <flo@rfc822.org>,
	linux-wireless@vger.kernel.org,
	Christian Casteyde <casteyde.christian@free.fr>,
	Martin Langer <martin-langer@gmx.de>,
	Stefano Brivio <st3@riseup.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Danny van Dyk <kugelfang@gentoo.org>,
	Andreas Jaggi <andreas.jaggi@waterwave.ch>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:7141 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbXIHLNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 07:13:10 -0400
Received: by ug-out-1314.google.com with SMTP id z38so345354ugc
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2007 04:13:09 -0700 (PDT)
In-Reply-To: <46E28149.2090900@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc5
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Linus Torvalds                         6
Andi Kleen                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
Al Viro                                3
Alan Stern                             3
Alexey Starikovskiy                    3
Cornelia Huck                          3
David S. Miller                        3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



Some of these patches are available in -krf (known regressions fixes) tree
http://www.stardust.webpages.pl/files/patches/krf/2.6.23-rc5-git1/linux-2.6.23-rc5-git1-krf1.patch.bz2
http://www.stardust.webpages.pl/files/patches/krf/2.6.23-rc5-git1/linux-2.6.23-rc5-git1-krf1.tar.bz2



MMC

Subject         : Unable to access memory card reader anymore
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8885
Last known good : ?
Submitter       : Christian Casteyde <casteyde.christian@free.fr>
Caused-By       : ?
Handled-By      : Alan Stern <stern@rowland.harvard.edu>
Patch           : http://bugzilla.kernel.org/attachment.cgi?id=12438
Status          : patch available



Networking

Subject         : ifconfig eth1 - scheduling while atomic: ifconfig/0x00000002/4170
References      : http://lkml.org/lkml/2007/9/2/165
Last known good : ?
Submitter       : Florian Lohoff <flo@rfc822.org>
Caused-By       : ?
Handled-By      : Johannes Berg <johannes@sipsolutions.net>
Patch           : http://lkml.org/lkml/2007/9/7/75
Status          : patch available

Subject         : System freeze when restarting network connection with Broadcom driver
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8934
Last known good : ?
Submitter       : Christian Casteyde <casteyde.christian@free.fr>
Caused-By       : ?
Handled-By      : ?
Status          : patch has been submitted to John Linville



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
