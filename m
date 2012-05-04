From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] macvtap: restore vlan header on user read
Date: Thu, 03 May 2012 21:06:59 -0400 (EDT)
Message-ID: <20120503.210659.243510666165033743.davem@davemloft.net>
References: <20120503231152.GA8602@nanobar>
	<20120503233029.GA31083@redhat.com>
	<20120503234732.GA26349@nanobar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: basil.gor@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab2EDBHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 21:07:07 -0400
In-Reply-To: <20120503234732.GA26349@nanobar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Basil Gor <basil.gor@gmail.com>
Date: Fri, 4 May 2012 03:47:33 +0400

> On Fri, May 04, 2012 at 02:30:29AM +0300, Michael S. Tsirkin wrote:
>> On Fri, May 04, 2012 at 03:11:52AM +0400, Basil Gor wrote:
>> > Below is a bit reworked version I've tested.
>> 
>> Will review thanks.
>> 
>> Can you add the signature according to the rules pls?
> 
> Copy vlan header to user when vlan id is stored in skb->vlan_tci
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

This doesn't work, you have to make the patch submission a
completely fresh one.  With a full, complete, commit message.

Not as a reply to another email posting.
