From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/3] drivers: net: xgene: Add separate tx
 completion ring
Date: Fri, 27 Mar 2015 14:21:04 -0700 (PDT)
Message-ID: <20150327.142104.396378238473908305.davem@davemloft.net>
References: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, kchudgar@apm.com,
	patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbC0VMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 17:12:30 -0400
In-Reply-To: <1427311152-30333-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Wed, 25 Mar 2015 12:19:09 -0700

> SGMII based 1GbE and 10GbE interfaces support multiple interrupts.
> Adding separate tx completion descriptor ring and associating a dedicated irq for the TX completion.
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>

Series applied, thanks.
