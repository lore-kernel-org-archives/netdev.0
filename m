From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix IPv6 ECN marking in RED
Date: Fri, 5 Mar 2004 23:26:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040305232635.51697517.davem@redhat.com>
References: <40491B9C.4040203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40491B9C.4040203@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 06 Mar 2004 01:30:20 +0100
Patrick McHardy <kaber@trash.net> wrote:

> this patch fixes IPv6 ECN marking in RED and changes it to use the
> functions from net/inet_ecn.h. Currently a local variable is marked
> instead of the packet.

Applied to both 2.4.x and 2.6.x, thanks Patrick.
