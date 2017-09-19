From: vcaputo@pengaru.com
Subject: Re: [PATCH] net: ethernet: aquantia: default to no in config
Date: Tue, 19 Sep 2017 16:02:49 -0700
Message-ID: <20170919230249.GB17797@shells.gnugeneration.com>
References: <20170919224315.GA17797@shells.gnugeneration.com>
 <20170919.155231.1474915838737685519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170919.155231.1474915838737685519.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 03:52:31PM -0700, David Miller wrote:
> From: Vito Caputo <vcaputo@pengaru.com>
> Date: Tue, 19 Sep 2017 15:43:15 -0700
> 
> > NET_VENDOR_AQUANTIA was "default y" for some reason, which seems
> > obviously inappropriate.
> 
> It is appropriate.
> 
> We make all vendor guards default to yes.

Thanks for the quick response.

Out of curiosity, what's the rationale for that decision?
