From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] bluetooth - set sock owner
Date: Sat, 30 Aug 2003 19:24:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830192431.32fc7183.davem@redhat.com>
References: <20030829112059.29414fc5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030829112059.29414fc5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:20:59 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> All sockets created by a protocol need to have owner field set
> to prevent problems with orphaned sockets during module unload.

Applied, thanks Stephen.
