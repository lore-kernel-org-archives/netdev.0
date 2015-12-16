From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Wed, 16 Dec 2015 12:19:21 +0100
Message-ID: <567148B9.9050906@stressinduktion.org>
References: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36904 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754550AbbLPLTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 06:19:23 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 1A5B420941
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 06:19:23 -0500 (EST)
In-Reply-To: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.12.2015 10:50, Xin Long wrote:
> Add the support for adding expire value to routes,  requested by
> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
> wants it too.
> 
> implement it by adding the new RTNETLINK attribute RTA_EXPIRES.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks, Xin Long!
