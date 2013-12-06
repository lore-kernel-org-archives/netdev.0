From: David Miller <davem@davemloft.net>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Fri, 06 Dec 2013 16:16:27 -0500 (EST)
Message-ID: <20131206.161627.917770459585726728.davem@davemloft.net>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
	<20131206.154321.1673089712073824539.davem@davemloft.net>
	<20131206131028.41b5b8b1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jtluka@redhat.com,
	zhiguohong@tencent.com, bridge@lists.linux-foundation.org,
	edumazet@google.com, laine@redhat.com, mst@redhat.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136Ab3LFVQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:16:31 -0500
In-Reply-To: <20131206131028.41b5b8b1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 6 Dec 2013 13:10:28 -0800

> How come you ignored my simpler fix, that used the existing logic.
> I don't like introducing this especially into the stable; much prefer
> to go back to testing the flag as was being done before.

I thought Jiri's response to your suggestion was adequate, that's
all.

I can revert and take your version if you want me to, just make
a formal submission and get agreement from Jiri.

Thanks.
