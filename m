From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 19:12:12 +0800
Message-ID: <47947E0C.1050301@cn.fujitsu.com>
References: <479469F8.4010203@cn.fujitsu.com>	<20080121.025722.147904573.davem@davemloft.net>	<47947B1F.7080709@cn.fujitsu.com> <20080121.030637.148068457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60741 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbYAULNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 06:13:35 -0500
In-Reply-To: <20080121.030637.148068457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-1-21 19:06:
> Does someone know how to setup GIT to update the HTTP
> fetch information as a post-push hook?
> 

Seems Herbert knows how to do it.
Maybe run git-update-server-info every time when you rebase
your tree.

>> Can you apply them to net-2.6 tree?
> 
> Done.
> 
Thanks.

--
WCN

