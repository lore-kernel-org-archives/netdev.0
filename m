From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: handle association restarts when the socket is
 closed.
Date: Mon, 06 Oct 2014 15:18:04 -0400 (EDT)
Message-ID: <20141006.151804.735956240011107584.davem@davemloft.net>
References: <1412374580-22286-1-git-send-email-vyasevich@gmail.com>
	<20141006.002229.1370132762577292096.davem@davemloft.net>
	<5432943E.7000505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbaJFTSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 15:18:07 -0400
In-Reply-To: <5432943E.7000505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 06 Oct 2014 09:08:14 -0400

> On 10/06/2014 12:22 AM, David Miller wrote:
>> Candidate for -stable?
> 
> I say yes.  If this problem is triggered it is total pain to get the memory
> clean-up.

Ok, queued up, thanks.
