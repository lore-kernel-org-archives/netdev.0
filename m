From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert /proc/net/packet to seq_file
Date: Mon, 5 Jan 2004 12:54:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105125456.05acad7b.davem@redhat.com>
References: <20040105121654.3cfbdfb6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040105121654.3cfbdfb6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 5 Jan 2004 12:16:54 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert AF_PACKET's /proc interface to seq_file. No change in functionality,
> but does fix problem with refcounting on this proc interface.

Applied, thanks Stephen.
