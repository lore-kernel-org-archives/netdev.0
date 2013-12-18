From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] dm9601: fix reception of full size ethernet frames
 on dm9620/dm9621a
Date: Wed, 18 Dec 2013 17:47:48 -0500 (EST)
Message-ID: <20131218.174748.2244739310468047343.davem@davemloft.net>
References: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
	<1387190135-17052-3-git-send-email-peter@korsgaard.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joseph_chang@davicom.com.tw,
	stable@vger.kernel.org
To: peter@korsgaard.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387190135-17052-3-git-send-email-peter@korsgaard.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 16 Dec 2013 11:35:33 +0100

> dm9620/dm9621a require room for 4 byte padding even in dm9601 (3 byte
> header) mode.
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Peter Korsgaard <peter@korsgaard.com>

Applied.
