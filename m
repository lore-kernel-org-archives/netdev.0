From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/19] net: Change variable type to bool
Date: Mon, 23 Sep 2013 17:38:37 -0400 (EDT)
Message-ID: <20130923.173837.1100130860877105243.davem@davemloft.net>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
	<1379802471-30252-9-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379802471-30252-9-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Using the same prefix, "net: " for several patches gives no information
to the person reading the shortlog.

Use more specific subsystem prefixes, such as "bnx2x: "myri10ge: ",
"ipv6: ", etc.
