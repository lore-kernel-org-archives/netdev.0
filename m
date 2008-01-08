From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 08 Jan 2008 09:42:26 -0800
Message-ID: <4783B602.1050307@linux.intel.com>
References: <477FF149.4070609@linux.intel.com>	<20080105213935.GN27894@ZenIV.linux.org.uk>	<20080107174431.GC27741@fieldses.org>	<4782CF9C.6000508@gmail.com>	<alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org> <20080108081401.d9576ac5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63172 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751438AbYAHRok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 12:44:40 -0500
In-Reply-To: <20080108081401.d9576ac5.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap wrote:
>>
>> (You can do it other and smarter ways too, I'm not claiming that's a 
>> particularly good way to do it, and the old "ksymoops" program used to do 
>> a pretty good job of this, but I'm used to that particular idiotic way 
>> myself, since it's how I've basically always done it)
> 
> One other way to do it (at least for x86-32/64) is to use
> $kerneltree/scripts/decodecode.  It may work on other $arches also,
> but I haven't tested it on others.

I've made life easier for those using the www.kerneloops.org website;
at least for x86 oopses the website now does this for you and shows
the decoded Code: line in the raw oops data:

http://www.kerneloops.org/raw.php?rawid=2716
