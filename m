From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] stmmac: CSR clock configuration fix
Date: Fri, 23 Dec 2016 11:46:48 -0500 (EST)
Message-ID: <20161223.114648.1048864820894046883.davem@davemloft.net>
References: <f586b394955d543470b614ddc8c5bc766c450c40.1482487963.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, seraphin.bonnaffe@st.com,
        hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, preid@electromag.com.au,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761323AbcLWQrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 11:47:00 -0500
In-Reply-To: <f586b394955d543470b614ddc8c5bc766c450c40.1482487963.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Fri, 23 Dec 2016 10:15:59 +0000

> When testing stmmac with my QoS reference design I checked a problem in the
> CSR clock configuration that was impossibilitating the phy discovery, since
> every read operation returned 0x0000ffff. This patch fixes the issue.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied, thank you.
