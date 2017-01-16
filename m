From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch net-next] stmmac: indent an if statement
Date: Mon, 16 Jan 2017 12:19:24 +0300
Message-ID: <20170116091924.GA4104@mwanda>
References: <20170112184631.GA12157@mwanda>
 <20170115.221438.1956356112755181222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, Joao.Pinto@synopsys.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170115.221438.1956356112755181222.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2017 at 10:14:38PM -0500, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Thu, 12 Jan 2017 21:46:32 +0300
> 
> > The break statement should be indented one more tab.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Applied, but like Julia I think we might have a missing of_node_put()
> here.

Of course, sorry for dropping the ball on this.  I'll send a patch for
that.

regards,
dan carpenter
