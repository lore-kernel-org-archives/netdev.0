From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] sctp: replace seq_printf with seq_puts
Date: Thu, 30 Oct 2014 19:40:43 -0400 (EDT)
Message-ID: <20141030.194043.767828738171481168.davem@davemloft.net>
References: <1414661356-17255-1-git-send-email-michele@acksyn.org>
	<1414661356-17255-2-git-send-email-michele@acksyn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: michele@acksyn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161577AbaJ3Xko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:40:44 -0400
In-Reply-To: <1414661356-17255-2-git-send-email-michele@acksyn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michele Baldessari <michele@acksyn.org>
Date: Thu, 30 Oct 2014 10:29:16 +0100

> Fixes checkpatch warning:
> "WARNING: Prefer seq_puts to seq_printf"
> 
> Signed-off-by: Michele Baldessari <michele@acksyn.org>

Applied.
