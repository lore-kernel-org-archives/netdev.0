From: David Miller <davem@davemloft.net>
Subject: Re: recvmsg sleeping from invalid context
Date: Sun, 22 Jan 2012 14:10:06 -0500 (EST)
Message-ID: <20120122.141006.530154674609252253.davem@davemloft.net>
References: <20120113182401.GA25885@redhat.com>
	<201201220854.59968.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: maciej.rutecki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab2AVTKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:10:13 -0500
In-Reply-To: <201201220854.59968.maciej.rutecki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Rutecki <maciej.rutecki@gmail.com>
Date: Sun, 22 Jan 2012 08:54:59 +0100

> I created a Bugzilla entry at 
> https://bugzilla.kernel.org/show_bug.cgi?id=42629
> for your bug report, please add your address to the CC list in there, thanks!

Please don't do this, none of the networking developers use bugzilla,
we keep the discussion and analysis going here on netdev.
