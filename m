From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/8 2.6.32] CVE-2010-4251: packet backlog can get too
 large
Date: Sun, 13 Nov 2011 22:24:10 -0500 (EST)
Message-ID: <20111113.222410.315752972470589717.davem@davemloft.net>
References: <20111113201336.GA1362@elgon.mountain>
	<20111113.155851.2167389434844487922.davem@davemloft.net>
	<1321226949.3059.13.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, stable@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, yi.zhu@intel.com, eric.dumazet@gmail.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab1KNDYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 22:24:30 -0500
In-Reply-To: <1321226949.3059.13.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 13 Nov 2011 23:29:09 +0000

> But you've previously said that you are not submitting networking
> patches to the longterm series.  Did you change your mind?

No, I in fact haven't.

But I will say that if distributions want to apply this thing, that's
fine, but it doesn't automatically make it a good idea for -stable
to take it too.
