From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.X] SIOCSIFNAME wilcard suppor & name validation
Date: Thu, 15 Jan 2004 00:49:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115004929.4b76ede2.davem@redhat.com>
References: <20040112234332.GA1785@bougret.hpl.hp.com>
	<20040113142204.0b41403b.shemminger@osdl.org>
	<20040113162112.509edb71.davem@redhat.com>
	<20040114161324.61b7198f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040114161324.61b7198f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 16:13:24 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Bug: dev_alloc_name returns the number of the slot used, so comparison needs
> to be < 0.

Applied, thanks Stephen.
