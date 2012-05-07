From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon, 07 May 2012 12:33:34 -0400 (EDT)
Message-ID: <20120507.123334.1735268146177880057.davem@davemloft.net>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120506.132513.36895742709809565.davem@davemloft.net>
	<1336374778.2386.1.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667Ab2EGQdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 12:33:38 -0400
In-Reply-To: <1336374778.2386.1.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 07 May 2012 00:12:58 -0700

> On Sun, 2012-05-06 at 13:25 -0400, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Sat,  5 May 2012 05:38:09 -0700
>> 
>> > This series of patches contains updates for e1000e and ixgbe.
>> > 
>> > NOTE- The ixgbe patch can and probably should be applied to
>> > David Miller's net tree as well.
>> > 
>> > The following are changes since commit bd14b1b2e29bd6812597f896dde06eaf7c6d2f24:
>> >   tcp: be more strict before accepting ECN negociation
>> > and are available in the git repository at:
>> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>> 
>> No new changes there?
>> 
>> [davem@drr net-next]$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>> From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
>>  * branch            master     -> FETCH_HEAD
>> Already up-to-date.
> 
> Sorry Dave, I thought I had pushed the changes but it appears I did not.
> I have rectified that and now my net-next tree contains the four
> patches.

That looks better, pulled, thanks Jeff.
