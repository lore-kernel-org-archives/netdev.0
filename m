From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] gue: Remote checksum offload
Date: Wed, 05 Nov 2014 16:44:11 -0500 (EST)
Message-ID: <20141105.164411.715023541101895981.davem@davemloft.net>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaKEVoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 16:44:13 -0500
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue,  4 Nov 2014 09:06:50 -0800

> This patch set implements remote checksum offload for
> GUE, which is a mechanism that provides checksum offload of
> encapsulated packets using rudimentary offload capabilities found in
> most Network Interface Card (NIC) devices.

Series applied, thanks for doing this work Tom.
