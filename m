From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] atm - set socket owner field
Date: Sat, 30 Aug 2003 19:07:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830190728.72e1599d.davem@redhat.com>
References: <20030829113758.6970f039.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030829113758.6970f039.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:37:58 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> All sockets created by a protocol need to have owner field set
> to prevent problems with orphaned sockets during module unload.

Applied, thanks.
