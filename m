From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: fix KSZ8041FTL supported value
Date: Wed, 23 Nov 2016 20:26:30 -0500 (EST)
Message-ID: <20161123.202630.1819148241081418408.davem@davemloft.net>
References: <1479747211-22394-1-git-send-email-yesipov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yesipov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479747211-22394-1-git-send-email-yesipov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Esipov <yesipov@gmail.com>
Date: Mon, 21 Nov 2016 19:53:31 +0300

> Fix setting of SUPPORTED_FIBRE bit as it was not present in features
> of KSZ8041.
> 
> Signed-off-by: Kirill Esipov <yesipov@gmail.com>

Applied.
