From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Exclude "All deletion of equal addresses only
 differing by prefix length."
Date: Thu, 31 Mar 2005 10:56:23 -0800
Message-ID: <20050331105623.3f04a84f.davem@davemloft.net>
References: <20050331124747.GT3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050331124747.GT3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 14:47:47 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> The address deletion fix is no longer needed since a better fix
> has made it into iproute2. Better in terms of same hack but in
> userspace so we don't confuse other netlink users.
> 
> Please do a
> 
> 	bk pull bk://kernel.bkbits.net/tgraf/net-2.6-trunk

Done, thanks Thomas.
