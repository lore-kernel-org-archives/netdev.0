From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Allow multiple dummy devices again
Date: Thu, 27 Nov 2003 17:40:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127174012.0bab844e.davem@redhat.com>
References: <20031128004445.GA2870@averell>
	<20031127171313.04f89baa.davem@redhat.com>
	<1069983202.1041.5.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069983202.1041.5.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27 Nov 2003 20:33:22 -0500
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2003-11-27 at 20:13, David S. Miller wrote:
> 
> > Even though we generally frown upon module options for networking
> > devices, I think it's wholly appropriate for this case.
> 
> Why not make it also a boot option?

They're one in the same these days.

If the driver is built as a module, you pass the option in with
at modload time, else you pass it in on the kernel command line.
