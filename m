From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qed: Fix error in the dcbx app meta data
 initialization.
Date: Tue, 25 Apr 2017 11:58:55 -0400 (EDT)
Message-ID: <20170425.115855.460238042941872050.davem@davemloft.net>
References: <20170425035910.29296-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: sudarsana.kalluru@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951146AbdDYP65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:58:57 -0400
In-Reply-To: <20170425035910.29296-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Date: Mon, 24 Apr 2017 20:59:10 -0700

> DCBX app_data array is initialized with the incorrect values for
> personality field. This would  prevent offloaded protocols from
> honoring the PFC.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Applied.
