From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] drivers: net: xgene: Fix coalescing bugs
Date: Tue, 01 Nov 2016 12:05:44 -0400 (EDT)
Message-ID: <20161101.120544.1150664206040874267.davem@davemloft.net>
References: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbcKAQFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:05:47 -0400
In-Reply-To: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 31 Oct 2016 16:00:25 -0700

> This patch set fixes the following,
> 
>      1. Since ethernet v1 hardware has a bug related to coalescing,
> 	disabling this feature
>      2. Fixing ethernet v2 hardware, interrupt trigger region
> 	id to 2, to kickoff coalescing
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
