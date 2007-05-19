From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [5/5] 2.6.22-rc2: known regressions
Date: Sun, 20 May 2007 00:06:33 +0200
Message-ID: <464F74E9.8080102__3247.60016887939$1179612488$gmane$org@googlemail.com>
References: <464F6DC9.80805@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Doug Chapman <doug.chapman@hp.com>,
	Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Ben Collins <bcollins@ubuntu.com>, yoshfuji@linux-ipv6.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764943AbXESWH7@vger.kernel.org>
In-Reply-To: <464F6DC9.80805@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc2.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Networking

Subject    : OOPS triggered by ip(8) deconfiguring a network interface
References : http://bugzilla.kernel.org/show_bug.cgi?id=8491
Submitter  : Ben Collins <bcollins@ubuntu.com>
Status     : Unknown

Subject    : panic with e1000 driver on HP Integrity servers
References : http://bugzilla.kernel.org/show_bug.cgi?id=8455
Submitter  : Doug Chapman <doug.chapman@hp.com>
Caused-By  : Auke Kok <auke-jan.h.kok@intel.com>
             commit e0aac5a289b1dacbc94bd9ae8c449bcdf9ab508c
Status     : problem is being debugged



Regards,
Michal

--
Michal K. K. Piotrowski
Kernel Monkeys
(http://kernel.wikidot.com/start)
