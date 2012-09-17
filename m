From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Take care of xfrm policy when checking
 dst entries
Date: Mon, 17 Sep 2012 14:25:04 -0400 (EDT)
Message-ID: <20120917.142504.115219640757684297.davem@davemloft.net>
References: <1347350987-8054-1-git-send-email-nicolas.dichtel@6wind.com>
	<20120917.124953.1599275868994343219.davem@davemloft.net>
	<5057688B.3030509@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, eric.dumazet@gmail.com,
	sds@tycho.nsa.gov, james.l.morris@oracle.com,
	eparis@parisplace.org, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab2IQSZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 14:25:09 -0400
In-Reply-To: <5057688B.3030509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Mon, 17 Sep 2012 14:14:35 -0400

> I think he expected you to take Eric's patch that removed those
> pieces.

Eric's patch was a cleanup, so it went into 'net-next'.

Nicolas's patch is a bonafide bug fix so needs to be
targetted at 'net'
