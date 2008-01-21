From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 03:06:37 -0800 (PST)
Message-ID: <20080121.030637.148068457.davem@davemloft.net>
References: <479469F8.4010203@cn.fujitsu.com>
	<20080121.025722.147904573.davem@davemloft.net>
	<47947B1F.7080709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbYAULGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:06:31 -0500
In-Reply-To: <47947B1F.7080709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 21 Jan 2008 18:59:43 +0800

> Dave, because the network of my working place can't clone git
> tree, I used 2.6.24-rc8 to make the patches.

Does someone know how to setup GIT to update the HTTP
fetch information as a post-push hook?

> Can you apply them to net-2.6 tree?

Done.
