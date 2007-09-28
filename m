From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Thu, 27 Sep 2007 21:28:45 -0600
Message-ID: <m1r6kjfoya.fsf@ebiederm.dsl.xmission.com>
References: <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
	<20070927.124552.69400277.davem@davemloft.net>
	<m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
	<20070927.171053.39175054.davem@davemloft.net>
	<20070927172533.1dd1db31.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38057 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898AbXI1D3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 23:29:13 -0400
In-Reply-To: <20070927172533.1dd1db31.akpm@linux-foundation.org> (Andrew
	Morton's message of "Thu, 27 Sep 2007 17:25:33 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 27 Sep 2007 17:10:53 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>
>> > I will gladly do what I can, to help.  Working against 3 trees
>> > development at the moment is a bit of a development challenge.
>> 
>> Andrew has to work against 30 or so
>
> I wish!  A remerge presently involves pulling and merging 73 git trees, 9
> quilt trees and maybe 1,500 -mm patches.

Yep.  There is a lot of chaos and keeping on top of it all is a pain,
and nobody has it easy.

Andrew probably wins award for the biggest challenge.

My todo list pales in comparison.   I only have 80+ patches in my
queue that I need to reviewed and then pushed upstream.  50 sysfs
patches to review and get a handle on so hopefully we can out of the
sysfs quagmire.

Plus I don't know how many little gotchas that need to be fixed with
a new patch of their own.

It's coming together but it takes time.  

David, Andrew thanks you both are really are good upstream maintainers
to work with.

Eric
