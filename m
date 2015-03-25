From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net 1/2] ipv4: take rtnl_lock and mark mrt table as freed on
 namespace cleanup
Date: Wed, 25 Mar 2015 21:23:04 +0100
Message-ID: <1427314984.3584557.245244521.1576A7B6@webmail.messagingengine.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49385 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbbCYUXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 16:23:05 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 05475201D5
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 16:23:01 -0400 (EDT)
In-Reply-To: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015, at 20:05, Cong Wang wrote:
> This is the IPv4 part for commit 905a6f96a1b1
> (ipv6: take rtnl_lock and mark mrt6 table as freed on namespace cleanup).
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
