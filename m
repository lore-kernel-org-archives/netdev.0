From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-timestamp: Fix a documentation typo
Date: Tue, 25 Nov 2014 13:35:53 -0500 (EST)
Message-ID: <20141125.133553.1368133884519204851.davem@davemloft.net>
References: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaKYSf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:35:56 -0500
In-Reply-To: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 24 Nov 2014 12:02:29 -0800

> SOF_TIMESTAMPING_OPT_ID puts the id in ee_data, not ee_info.
> 
> Cc: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Applied, thanks Andy.
