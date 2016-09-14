From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/9] net: ethernet: ti: cpts: move dt props parsing to
 cpts driver
Date: Wed, 14 Sep 2016 15:55:35 +0200
Message-ID: <20160914135535.GB28592@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914130231.3035-5-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 04:02:26PM +0300, Grygorii Strashko wrote:
> Move DT properties parsing into CPTS driver to simplify consumer's
> code and CPTS driver porting on other SoC in the future
> (like Keystone 2).

And just who is the consumer?
 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 16 +---------------
>  drivers/net/ethernet/ti/cpsw.h |  2 --
>  drivers/net/ethernet/ti/cpts.c | 29 ++++++++++++++++++++++++++---
>  drivers/net/ethernet/ti/cpts.h |  5 +++--
>  4 files changed, 30 insertions(+), 22 deletions(-)

You have more (+) than (-).  I wouldn't call that a simplification.

Thanks,
Richard
