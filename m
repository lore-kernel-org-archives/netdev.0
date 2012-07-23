From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFT RESEND] net: Fix Neptune ethernet driver to check
 dma mapping error
Date: Sun, 22 Jul 2012 23:34:57 -0700 (PDT)
Message-ID: <20120722.233457.2263398598927809265.davem@davemloft.net>
References: <1342821035.5434.60.camel@lorien2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shuahkhan@gmail.com,
	stable@vger.kernel.org
To: shuah.khan@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342821035.5434.60.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 20 Jul 2012 15:50:35 -0600

> Fix Neptune ethernet driver to check dma mapping error after map_page()
> interface returns.
> 
> Signed-off-by: Shuah Khan <shuah.khan@hp.com>

Applied.
