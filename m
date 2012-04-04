From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 7/8] net/dcb: Add an optional max rate
 attribute
Date: Wed, 04 Apr 2012 18:28:38 -0400 (EDT)
Message-ID: <20120404.182838.86622924907738367.davem@davemloft.net>
References: <4F7C6D3C.7070807@intel.com>
	<CAJZOPZKLtvtfD+o81V0Ezs7NSeTnmp-dBtHPhmziypHkpyOWtw@mail.gmail.com>
	<CAJZOPZKDBECDx0_Yy7N12d8we92N-=0PAOryqOYmmiJ7n7Z1dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	john.r.fastabend@intel.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753556Ab2DDW2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:28:46 -0400
In-Reply-To: <CAJZOPZKDBECDx0_Yy7N12d8we92N-=0PAOryqOYmmiJ7n7Z1dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Thu, 5 Apr 2012 01:27:29 +0300

> Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> John Fastabend <john.r.fastabend@intel.com> wrote:
>>> And I think the last comment. We really should have a comment here describing
>>> what the tc_maxrate field is. Its described in the commit log but its much
>>> harder for implementers to get it wrong when the struct is annotated.
> 
>> Okay, John, sure, we can add that, so just to make sure, from your
>> side the series is okay once this comment is added, correct?
> 
> Also, Dave, any further comments from you on this series, or with
> adding that comment John was asking for - the patches are all fine?

Yep, they seem mostly fine to me.  So please resubmit with the comment
fix.
