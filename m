From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/9] net: ethernet: ti: cpts: move dt props parsing to
 cpts driver
Date: Wed, 14 Sep 2016 22:03:46 +0200
Message-ID: <20160914200342.GA12195@netboy>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-5-grygorii.strashko@ti.com>
 <20160914135535.GB28592@localhost.localdomain>
 <179724dc-dcc2-6052-84c6-eef9807d867c@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <179724dc-dcc2-6052-84c6-eef9807d867c@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 10:45:54PM +0300, Grygorii Strashko wrote:
> With this change It will not be required to add the same DT parsing code
> in Keystone 2 netcp driver, so overall number of lines will be reduced.

This explanation would make the commit message much more informative.

Thanks,
Richard
