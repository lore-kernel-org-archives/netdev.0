From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: make channel_ops const
Date: Wed, 04 Aug 2010 21:56:09 -0700 (PDT)
Message-ID: <20100804.215609.191412753.davem@davemloft.net>
References: <20100804103436.72e234d6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100804103436.72e234d6@nehalam>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Aug 2010 10:34:36 -0700

> The PPP channel ops structure should be const.
> Cleanup the declarations to use standard C99 format.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
