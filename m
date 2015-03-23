From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Move the comment about unsettable
 socket-level options to default clause and update its reference.
Date: Mon, 23 Mar 2015 16:55:41 -0400 (EDT)
Message-ID: <20150323.165541.1457861247015573488.davem@davemloft.net>
References: <550FD70D.9080500@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbCWUzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:55:43 -0400
In-Reply-To: <550FD70D.9080500@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Mon, 23 Mar 2015 18:04:13 +0900

> We implement the SO_SNDLOWAT etc not to be settable and return
> ENOPROTOOPT per 1003.1g 7.  Move the comment to appropriate
> position and update the reference.
> 
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
