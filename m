From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Allow multiple dummy devices again
Date: Fri, 28 Nov 2003 00:30:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128003040.76abab84.davem@redhat.com>
References: <20031128004445.GA2870@averell>
	<20031127171313.04f89baa.davem@redhat.com>
	<1069983202.1041.5.camel@jzny.localdomain>
	<20031127174012.0bab844e.davem@redhat.com>
	<20031128070437.A5765@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, ak@muc.de, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20031128070437.A5765@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Nov 2003 07:04:37 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> You'd have to use module_param for that, but it appears the driver uses
> the deprectated MODULE_PARAM..

Indeed, that should be fixed.  Good catch.
