From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Tue, 6 Dec 2016 21:25:59 +0100
Message-ID: <20161206202558.GB23605@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
 <20161130095632.GC28680@localhost.localdomain>
 <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
 <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Murali Karicheri <m-karicheri2@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
        linux-clk@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-clk-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11994fbc-3713-6ef7-8a44-8a2442106dfc@ti.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2016 at 01:39:40PM -0600, Grygorii Strashko wrote:
> I come with below RFC patch. if no objection I'll move forward with it.

Thanks for following through with this!

The am335x will also need the MUX in its clock tree, won't it?


Thanks,
Richard
