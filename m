From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] stmmac: Add vlan rx for better GRO
 performance.
Date: Wed, 15 Jan 2014 15:13:31 -0800 (PST)
Message-ID: <20140115.151331.947371618474336706.davem@davemloft.net>
References: <1389728525-6989-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	rayagond@vayavyalabs.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbaAOXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:13:32 -0500
In-Reply-To: <1389728525-6989-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Tue, 14 Jan 2014 13:42:05 -0600

> GRO requires VLANs to be removed before aggregation can occur.
> The Synopsys EMAC does not strip VLAN tags so this must be
> done by the driver.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V2: remove inline on added function, line up broken lines per review comments

Applied, thanks.
