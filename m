From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: dwc-qos-eth: Fix typo in DT bindings
 parsing
Date: Fri, 27 Oct 2017 23:26:26 +0900 (KST)
Message-ID: <20171027.232626.1005407369555650792.davem@davemloft.net>
References: <20c97192a6c490fbcba8fa331dd979699700a118.1509007831.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
To: Jose.Abreu@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20c97192a6c490fbcba8fa331dd979699700a118.1509007831.git.joabreu@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jose Abreu <Jose.Abreu@synopsys.com>
Date: Thu, 26 Oct 2017 09:51:33 +0100

> According to DT bindings documentation we are expecting a
> property called "snps,read-requests" but we are parsing
> instead a property called "read,read-requests".
> 
> This is clearly a typo. Fix it.
> 
> Signed-off-by: Jose Abreu <joabreu@synopsys.com>

Applied, thank you!
