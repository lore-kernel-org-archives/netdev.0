From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X.25 Add missing sock_put in x25_receive_data
Date: Mon, 15 Jan 2007 19:28:46 -0800 (PST)
Message-ID: <20070115.192846.85406756.davem@davemloft.net>
References: <1168295537.5460.30.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, eis@baty.hanse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: ahendry@tusc.com.au
In-Reply-To: <1168295537.5460.30.camel@localhost>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ahendry <ahendry@tusc.com.au>
Date: Tue, 09 Jan 2007 09:32:17 +1100

> __x25_find_socket does a sock_hold.
> This adds a missing sock_put in x25_receive_data.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied, thanks a lot.
