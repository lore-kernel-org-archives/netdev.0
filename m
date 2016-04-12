From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] FUJITSU Extended Socket driver version
 1.1
Date: Tue, 12 Apr 2016 11:43:47 -0400 (EDT)
Message-ID: <20160412.114347.238466820533443675.davem@davemloft.net>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<20160411.115617.2124648532876219571.davem@davemloft.net>
	<E86EADE93E2D054CBCD4E708C38D364A734EF16E@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965831AbcDLPnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 11:43:51 -0400
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A734EF16E@G01JPEXMBYT01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Date: Tue, 12 Apr 2016 08:35:09 +0000

>  But I'd like to keep some debugfs facility for status information
>  and some specific stats other thatn net_stats.

We have a facility for arbitrary driver stats, remove this debugfs crap
please.

I'm not going to say this again.
