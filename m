From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/2] 2.6.22-rc4: known regressions v3
Date: Wed, 13 Jun 2007 21:57:56 +0200
Message-ID: <46704C44.8020602@googlemail.com>
References: <46704923.1010009@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Dan Aloni <da-x@monatomic.org>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mikael Pettersson <mikpe@it.uu.se>,
	linux-pm@lists.linux-foundation.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	linux-usb-devel@lists.sourceforge.net,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Alex Riesen <raa.lkml@gmail.com>, Andi Kleen <ak@suse.de>,
	discuss@x86-64.org, Ioan Ionita <opslynx@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:53133 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245AbXFMT67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 15:58:59 -0400
Received: by mu-out-0910.google.com with SMTP id i10so412218mue
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 12:58:58 -0700 (PDT)
In-Reply-To: <46704923.1010009@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc4.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions



Networking

Subject    : commit 9093bbb2d96d0184f037cea9b4e952a44ebe7c32 broke the bonding driver
References : http://lkml.org/lkml/2007/6/13/65
Submitter  : Dan Aloni <da-x@monatomic.org>
Handled-By : Stephen Hemminger <shemminger@linux-foundation.org>
Status     : Unknown



Sparc64

Subject    : 2.6.22-rc broke X on Ultra5
References : http://lkml.org/lkml/2007/5/22/78
Submitter  : Mikael Pettersson <mikpe@it.uu.se>
Handled-By : David Miller <davem@davemloft.net>
Status     : problem is being debugged



Suspend

Subject    : hibernate(?) fails totally - regression
References : http://lkml.org/lkml/2007/6/1/401
Submitter  : David Greaves <david@dgreaves.com>
Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
Caused-By  : Tejun Heo <htejun@gmail.com>
             commit 9666f4009c22f6520ac3fb8a19c9e32ab973e828
Status     : problem is being debugged



TTY

Subject    : OOPS (NULL pointer dereference) in v2.6.22-rc3
References : http://lkml.org/lkml/2007/6/1/389
             http://bugzilla.kernel.org/show_bug.cgi?id=8473
             http://bugzilla.kernel.org/show_bug.cgi?id=8574
Submitter  : Alex Riesen <raa.lkml@gmail.com>
Status     : problem is being debugged



x86-64

Subject    : x86-64 2.6.22-rc2 random segfaults
References : http://lkml.org/lkml/2007/5/24/275
Submitter  : Ioan Ionita <opslynx@gmail.com>
Status     : Unknown



Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
