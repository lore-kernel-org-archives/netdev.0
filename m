From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: CSR clock configuration fix
Date: Thu, 22 Dec 2016 11:21:04 -0500 (EST)
Message-ID: <20161222.112104.582962372375835173.davem@davemloft.net>
References: <7b395fd7dfd0c808243a744393473cbbf89b268a.1482410161.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, seraphin.bonnaffe@st.com,
        hock.leong.kweh@intel.com, niklas.cassel@axis.com, pavel@ucw.cz,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7b395fd7dfd0c808243a744393473cbbf89b268a.1482410161.git.jpinto@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Thu, 22 Dec 2016 12:38:00 +0000

> When testing stmmac with my QoS reference design I checked a problem in the
> CSR clock configuration that was impossibilitating the phy discovery, since
> every read operation returned 0x0000ffff. This patch fixes the issue.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>

Applied.
