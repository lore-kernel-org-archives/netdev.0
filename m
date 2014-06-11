From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: Add VF link state control policy
Date: Tue, 10 Jun 2014 20:47:24 -0700 (PDT)
Message-ID: <20140610.204724.1766248023965511967.davem@davemloft.net>
References: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
	<539765F4.10506@cogentembedded.com>
	<1402431128.9149.8.camel@firewall.xsintricity.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	ronye@mellanox.com, ogerlitz@mellanox.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbaFKDrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 23:47:25 -0400
In-Reply-To: <1402431128.9149.8.camel@firewall.xsintricity.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Tue, 10 Jun 2014 16:12:08 -0400

> On Wed, 2014-06-11 at 00:09 +0400, Sergei Shtylyov wrote:
>> Hello.
>> 
>> On 06/10/2014 11:59 PM, Doug Ledford wrote:
>> 
>> > Commit 1d8faf48c7 added VF link state control to the netlink VF nested
>> 
>>     Please also specify that commit's summary line in parens.
> 
> It was almost a carbon copy of my own commit summary:
> 
> (net/core: Add VF link state control)

But that is the way we absolutely require commits to be referred to,
SHA IDs are ambiguous, especially when changes are backported into
other trees.  Given that, the only unambiguous thing left is the
precise text of the commit header line.

That's why I require it to be explicitly provided alongside commit's
referred to in commit messages.
