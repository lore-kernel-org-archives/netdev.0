From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sctp: wake up all assocs if sndbuf policy
 is per socket
Date: Tue, 08 Apr 2014 14:46:01 -0400 (EDT)
Message-ID: <20140408.144601.1499418906739470715.davem@davemloft.net>
References: <20140408.131819.1373401078750444800.davem@davemloft.net>
	<53442FD0.5020609@redhat.com>
	<20140408.141918.1353780924646899277.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com, vyasevic@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757243AbaDHSqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 14:46:06 -0400
In-Reply-To: <20140408.141918.1353780924646899277.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Daniel and Vlad, I'm about to send Linus a pull request.

I know that you still need to fixup this SCTP change and it'll be
in there, but I really need to get the changes in my tree staged
so that I can do a set of -stable submissions.

So please don't freak out, I know that this change still needs work
and shouldn't go to -stable just yet :-)
