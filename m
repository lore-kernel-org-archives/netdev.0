From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] [IPV4]: Exclude "All deletion of equal addresses only
 differing by prefix length."
Date: Thu, 31 Mar 2005 20:48:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.61.0503312047110.26294@netcore.fi>
References: <20050331124747.GT3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050331124747.GT3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005, Thomas Graf wrote:
> The address deletion fix is no longer needed since a better fix
> has made it into iproute2. Better in terms of same hack but in
> userspace so we don't confuse other netlink users.

So, does that mean that all the users are expected to always run the 
latest iproute2, so there's no need for backward-compat in the kernel?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
