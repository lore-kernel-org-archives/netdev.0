From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]net:8021q:vlan.c Fix pr_info to read on line in the
 syslog.
Date: Mon, 23 May 2011 15:56:30 -0400 (EDT)
Message-ID: <20110523.155630.1404321441037491870.davem@davemloft.net>
References: <1306166698-2036-1-git-send-email-justinmattock@gmail.com>
	<1306167781.8687.20.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: justinmattock@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306167781.8687.20.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 23 May 2011 09:23:01 -0700

> though I think that emitting names on startup isn't necessary and
> this is enough:

Agreed, it's not like Ben and I are Napoleon or anything...
