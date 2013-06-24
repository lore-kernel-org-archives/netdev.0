From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] VSOCK fix and cleanup
Date: Sun, 23 Jun 2013 23:52:15 -0700 (PDT)
Message-ID: <20130623.235215.1378819992781353051.davem@davemloft.net>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acking@vmware.com, dtor@vmware.com,
	grantr@vmware.com
To: asias@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab3FXGwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 02:52:19 -0400
In-Reply-To: <1371720033-19714-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asias He <asias@redhat.com>
Date: Thu, 20 Jun 2013 17:20:29 +0800

> 
> Asias He (4):
>   VSOCK: Introduce vsock_auto_bind helper
>   VSOCK: Return VMCI_ERROR_NO_MEM when fails to allocate skb
>   VSOCK: Remove unnecessary label
>   VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH

Series applied to net-next, thanks.
