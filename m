From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ipx - set socket owner field
Date: Sat, 30 Aug 2003 19:06:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830190650.0a785a8c.davem@redhat.com>
References: <20030829113704.548a9af4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030829113704.548a9af4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:37:04 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> All sockets created by a protocol need to have owner field set
> to prevent problems with orphaned sockets during module unload.

Applied, thanks.
