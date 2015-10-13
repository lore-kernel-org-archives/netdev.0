From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sock: support per-packet fwmark
Date: Mon, 12 Oct 2015 19:25:51 -0700 (PDT)
Message-ID: <20151012.192551.1983531977410734176.davem@davemloft.net>
References: <1444341409-28729-1-git-send-email-edjee@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, willemb@google.com
To: edjee@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100AbbJMCJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:09:51 -0400
In-Reply-To: <1444341409-28729-1-git-send-email-edjee@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Hyunkoo Jee <edjee@google.com>
Date: Thu,  8 Oct 2015 14:56:48 -0700

> It's useful to allow users to set fwmark for an individual packet,
> without changing the socket state. The function this patch adds in
> sock layer can be used by the protocols that need such a feature.
> 
> Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
