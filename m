From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] mark dev_alloc as deprecated.
Date: Tue, 14 Oct 2003 13:16:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014131641.42c545b5.davem@redhat.com>
References: <20031014111940.709280d7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031014111940.709280d7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Oct 2003 11:19:40 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> dev_alloc is an older way of getting a network device.  Most uses of it are gone,
> and it was usually used in an unsafe way.  The remaining usage in 2.6.0-test7
> are in arcnet devices.

Applied, thanks Stephen.
