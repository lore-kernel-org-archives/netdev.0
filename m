From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] hostess -- return value check for register_netdev
Date: Sat, 11 Oct 2003 12:12:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031011121234.01bbe577.davem@redhat.com>
References: <20031009112714.18742308.shemminger@osdl.org>
	<20031010000158.2dc9ce78.davem@redhat.com>
	<20031010103225.2177d385.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031010103225.2177d385.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 10:32:25 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Another driver that checks for register_netdev returing -1 when
> it can return -EIO or -EEXIST.

Applied, thanks Stephen.
