From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Vlan convert stubs to no-ops
Date: Mon, 28 Jul 2003 16:28:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728162824.47f16322.davem@redhat.com>
References: <20030728152114.02a10f4e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, vlan@wanfear.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030728152114.02a10f4e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 15:21:14 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When building without /proc, the interfaces can be converted to no-ops
> (very minor code savings).

Applied to 2.6.x, thanks Stephen.
