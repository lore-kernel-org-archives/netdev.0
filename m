From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: renesas: ravb_main: don't open code
 of_device_get_match_data()
Date: Thu, 03 Mar 2016 16:39:03 -0500 (EST)
Message-ID: <20160303.163903.1215736510298862413.davem@davemloft.net>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa@the-dreams.de>
Date: Tue,  1 Mar 2016 17:37:58 +0100

> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> 
> This change will also make Coverity happy by avoiding a theoretical NULL
> pointer dereference; yet another reason is to use the above helper function
> to tighten the code and make it more readable.
> 
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

Applied.
