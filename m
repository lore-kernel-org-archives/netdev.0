From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.X] SIOCSIFNAME wilcard suppor & name validation
Date: Tue, 13 Jan 2004 16:21:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113162112.509edb71.davem@redhat.com>
References: <20040112234332.GA1785@bougret.hpl.hp.com>
	<20040113142204.0b41403b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040113142204.0b41403b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 14:22:04 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is an enhanced version of the previous patch.
> It adds both the wildcard support that Jean did, and validation of network
> device names.
> 
> It doesn't check the error return from class_device_rename because
> that will not fail unless object or name are null.

This is really cool, nice work guys.

Patch applied, thanks.
