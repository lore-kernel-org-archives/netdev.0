From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] econet - set socket owner field
Date: Sat, 30 Aug 2003 19:06:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830190602.53aaa259.davem@redhat.com>
References: <20030829111855.1425b7aa.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030829111855.1425b7aa.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:18:55 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> All sockets created by a protocol need to have owner field set
> to prevent problems with orphaned sockets during module unload.

Applied, thanks.
