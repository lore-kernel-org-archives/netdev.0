From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dvb-net -- allocate network device structures
Date: Wed, 8 Oct 2003 08:43:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008084346.457e927b.davem@redhat.com>
References: <20031007172257.7dff3075.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kraxel@bytesex.org, video4linux-list@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031007172257.7dff3075.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Oct 2003 17:22:57 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch to 2.6.0-test6 converts the DVB net driver to allocate network
> devices structures in a manner similar to other network devices in 2.6 by
> using alloc_netdev.  Instead of an array of structures, and array of pointers
> is used.

Applied, thanks.
