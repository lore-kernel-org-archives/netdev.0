From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/4] 2.6.23-rc5: known regressions v2
Date: Sat, 08 Sep 2007 13:11:20 +0200
Message-ID: <46E28358.9020408@googlemail.com>
References: <46E27DEF.7060109@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>,
	dth <dth@dth.net>, Netdev <netdev@vger.kernel.org>,
	Shish <shish@shishnet.org>, Karl Meyer <adhocrocker@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Daniel Drake <dsd@gentoo.org>,
	Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net,
	Christian Kujau <lists@nerdbynature.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:7419 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbXIHLMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 07:12:49 -0400
Received: by ug-out-1314.google.com with SMTP id z38so345355ugc
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2007 04:12:48 -0700 (PDT)
In-Reply-To: <46E27DEF.7060109@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc5.

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



CPUFREQ

Subject         : ide problems: 2.6.22-git17 working, 2.6.23-rc1* is not
References      : http://lkml.org/lkml/2007/7/27/298
                  http://lkml.org/lkml/2007/7/29/371
Last known good : ?
Submitter       : dth <dth@dth.net>
Caused-By       : Len Brown <lenb@kernel.org>
                  commit f79e3185dd0f8650022518d7624c876d8929061b
Handled-By      : Len Brown <lenb@kernel.org>
Status          : problem is being debugged



Networking

Subject         : 2.6.23-rc5: possible irq lock inversion dependency detected
References      : http://lkml.org/lkml/2007/9/2/97
Last known good : ?
Submitter       : Christian Kujau <lists@nerdbynature.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : zd1211rw regression, device does not enumerate
References      : http://marc.info/?l=linux-usb-devel&m=118854967709322&w=2
                  http://bugzilla.kernel.org/show_bug.cgi?id=8972
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
