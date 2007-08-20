From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.23-rc3: known regressions with patches v2
Date: Mon, 20 Aug 2007 18:02:06 +0200
Message-ID: <46C9BAFE.7060104@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Pierre Ossman <drzeus-mmc@drzeus.cx>,
	Christian Casteyde <casteyde.christian@free.fr>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-mtd@lists.infradead.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	"Daniel K." <daniel@cluded.net>, Florian Lohoff <flo@rfc822.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:5378 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760228AbXHTQCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:02:32 -0400
Received: by nf-out-0910.google.com with SMTP id g13so667137nfb
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 09:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc3
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            9
Andi Kleen                             5
Linus Torvalds                         5
Andrew Morton                          4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3



Unclassified

Subject         : Oops while modprobing phy fixed module
References      : http://lkml.org/lkml/2007/7/14/63
Last known good : ?
Submitter       : Gabriel C <nix.or.die@googlemail.com>
Caused-By       : ?
Handled-By      : Satyam Sharma <satyam.sharma@gmail.com>
                  Vitaly Bordug <vitb@kernel.crashing.org>
Patch1          : http://lkml.org/lkml/2007/7/18/506
Status          : patch available



MMC

Subject         : Unable to access memory card reader anymore
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8885
Last known good : ?
Submitter       : Christian Casteyde <casteyde.christian@free.fr>
Caused-By       : ?
Handled-By      : Alan Stern <stern@rowland.harvard.edu>
Patch           : http://bugzilla.kernel.org/attachment.cgi?id=12438
Status          : patch available



MTD

Subject         : error: implicit declaration of function 'cfi_interleave'
References      : http://lkml.org/lkml/2007/8/6/272
Last known good : ?
Submitter       : Ingo Molnar <mingo@elte.hu>
Caused-By       : ?
Handled-By      : David Woodhouse <dwmw2@infradead.org>
Patch           : http://lkml.org/lkml/2007/8/9/586
Status          : patch available



Networking

Subject         : BUG: when using 'brctl stp'
References      : http://lkml.org/lkml/2007/8/10/441
Last known good : 2.6.23-rc1
Submitter       : Daniel K. <daniel@cluded.net>
Caused-By       : ?
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : fix applied by David Miller


Subject         : sky2 boot crash in sky2_mac_intr
References      : http://lkml.org/lkml/2007/7/24/91
Last known good : ?
Submitter       : Florian Lohoff <flo@rfc822.org>
Caused-By       : 
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Patch           : http://marc.info/?l=linux-netdev&m=118651402523966&w=2
Status          : patch available


Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
