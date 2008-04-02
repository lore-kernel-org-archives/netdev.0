From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Wed, 02 Apr 2008 00:10:48 -0700 (PDT)
Message-ID: <20080402.001048.267915281.davem@davemloft.net>
References: <1206978361.10660.31.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757560AbYDBHKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 03:10:47 -0400
In-Reply-To: <1206978361.10660.31.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon, 31 Mar 2008 19:46:01 +0400

> Hello, Dave!
> 
> Recently I have seen several issues post to the netdev@ blaming
> inclusion of the net_namespace.h from seq_file. This set fixes this
> problem after two small cleanups.

All applied, thanks Denis.

I'll push to net-2.6.26 after some build sanity checks.
