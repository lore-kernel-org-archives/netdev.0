From: Rene Herman <rene.herman@keyaccess.nl>
Subject: Re: Reporting bugs and bisection
Date: Mon, 14 Apr 2008 21:13:41 +0200
Message-ID: <4803ACE5.4020502@keyaccess.nl>
References: <47FEADCB.7070104@rtr.ca>	<20080413121831.d89dd424.akpm@linux-foundation.org>	<20080413202118.GA29658@2ka.mipt.ru>	<200804132233.50491.rjw@sisk.pl>	<20080413205406.GA9190@2ka.mipt.ru>	<48028830.6020703@earthlink.net>	<alpine.DEB.1.10.0804131546370.9318@asgard>	<20080414043939.GA6862@1wt.eu>	<20080414053943.GU9785@ZenIV.linux.org.uk> <20080413232441.e216a02c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Willy Tarreau <w@1wt.eu>,
	david@lang.hm, Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpq1.groni1.gr.home.nl ([213.51.130.200]:42584 "EHLO
	smtpq1.groni1.gr.home.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbYDNTLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 15:11:49 -0400
In-Reply-To: <20080413232441.e216a02c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-04-08 08:24, Andrew Morton wrote:

> On Mon, 14 Apr 2008 06:39:43 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

>> I have a related proposal: let us require all patches to be stamped
>> with Discordian *and* Eternal September dates.  In triplicate.  While
>> we are at it, why don't we introduce new mandatory headers like, say
>> it,
>>
>> X-checkpatch: {Yes,No}
>> X-checkpatch-why-not: <string>
>> X-pointless: <number from 1 to 69, going from "1: does something useful" all
>> the way to "68: aligns right ends of lines in comments">
>> X-arbitrary-rules-added-to-CodingStyle: <number> (should be present if
>> and only if X-pointless: 69 is present).
>>
>> Come to think of that, we clearly need a new file in Documentation/*,
>> documenting such headers.  Why don't we organize a subcommittee^Wnew maillist
>> devoted to that?  That would provide another entry route for contributors,
>> lowering the overall entry barriers even further...
>>
> 
> None of the above was particularly useful.

Does that mean you're not going to take patches that align the right end of 
lines in comments? :-(

Rene.
