From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selinux/nlmsg: add a build time check for
 rtnl/xfrm cmds
Date: Mon, 13 Apr 2015 13:10:01 -0400 (EDT)
Message-ID: <20150413.131001.36872142001320075.davem@davemloft.net>
References: <1428931237-22679-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1428931237-22679-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 13 Apr 2015 15:20:37 +0200

> When a new rtnl or xfrm command is added, this part of the code is frequently
> missing. Let's help the developer with a build time test.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Yeah, I like stuff like this.

Applied, thanks!
