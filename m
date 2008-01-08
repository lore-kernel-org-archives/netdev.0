From: Kevin Winchester <kjwinchester@gmail.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Mon, 07 Jan 2008 21:19:24 -0400
Message-ID: <4782CF9C.6000508@gmail.com>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758576AbYAHBTi@vger.kernel.org>
In-Reply-To: <20080107174431.GC27741@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J. Bruce Fields wrote:
> On Sat, Jan 05, 2008 at 09:39:35PM +0000, Al Viro wrote:
>> On Sat, Jan 05, 2008 at 01:06:17PM -0800, Arjan van de Ven wrote:
>>> The http://www.kerneloops.org website collects kernel oops and 
>>> warning reports from various mailing lists and bugzillas as well 
>>> as with a client users can install to auto-submit oopses. Below 
>>> is a top 10 list of the oopses collected in the last 7 days. 
>>> (Reports prior to 2.6.23 have been omitted in collecting the top 
>>> 10)
>>> 
>>> This week, a total of 49 oopses and warnings have been reported,
>>>  compared to 53 reports in the previous week.
>> FWIW, people moaning about the lack of entry-level kernel work 
>> would do well by decoding those to the level of "this place in this
>>  function, called from <here>, with so-and-so variable being
>> <this>" and posting the results.  As skills go, it's far more
>> useful than "how to trim the trailing whitespace" and the rest of 
>> checkpatch.pl-inspired crap that got so popular lately...
> 
> Is there any good basic documentation on this to point people at?
> 

I would second this question.  I see people "decode" oops on lkml often enough, but I've never been entirely sure how its done.  Is it somewhere in Documentation?

-- 
Kevin Winchester
