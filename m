From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: factorize ifname_compare()
Date: Wed, 25 Mar 2009 17:32:21 +0100
Message-ID: <49CA5C95.50409@trash.net>
References: <20090324.132954.148903398.davem@davemloft.net> <49C94B6A.5020304@cosmosbay.com> <alpine.LSU.2.00.0903242215590.26397@fbirervta.pbzchgretzou.qr> <20090324.141848.119353425.davem@davemloft.net> <alpine.LSU.2.00.0903242220280.26397@fbirervta.pbzchgretzou.qr> <49C952FE.7070202@cosmosbay.com> <alpine.LSU.2.00.0903242243040.3974@fbirervta.pbzchgretzou.qr> <49CA150B.2080203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34204 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758345AbZCYQc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 12:32:28 -0400
In-Reply-To: <49CA150B.2080203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] netfilter: factorize ifname_compare()
> 
> We use same not trivial helper function in four places. We can factorize it.

Applied, thanks a lot Eric.
