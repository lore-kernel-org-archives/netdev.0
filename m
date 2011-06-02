From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next when it opens] net: 8021q: Add pr_fmt
Date: Thu, 02 Jun 2011 14:03:48 -0700 (PDT)
Message-ID: <20110602.140348.1547123834732953969.davem@davemloft.net>
References: <20110526.145601.735416831290933990.davem@davemloft.net>
	<6d2f6a1e6365b8865fd210e88d257ca0bc7ad0fa.1306442986.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, greearb@candelatech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6d2f6a1e6365b8865fd210e88d257ca0bc7ad0fa.1306442986.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 26 May 2011 13:58:31 -0700

> Use the current logging style.
> 
> Add #define pr_fmt and remove embedded prefix from formats.
> 
> Not converting the current pr_<level> uses to netdev_<level>
> because all the output here is nicely prefaced with "8021q: ".
> 
> Remove __func__ use from proc registration failure message.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I'll apply this, thanks Joe.
