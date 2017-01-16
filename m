From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] stmmac: indent an if statement
Date: Sun, 15 Jan 2017 22:14:38 -0500 (EST)
Message-ID: <20170115.221438.1956356112755181222.davem@davemloft.net>
References: <20170112184631.GA12157@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, Joao.Pinto@synopsys.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112184631.GA12157@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 12 Jan 2017 21:46:32 +0300

> The break statement should be indented one more tab.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, but like Julia I think we might have a missing of_node_put()
here.
