From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH bk-2.6.10] tg3:align IP headers from 5701 in PCI-X mode
Date: Mon, 17 Jan 2005 14:12:01 -0800
Message-ID: <20050117141201.37b0fda7.davem@davemloft.net>
References: <Pine.LNX.4.21.0501111242590.14715-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Arthur D. Kepner" <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.21.0501111242590.14715-100000@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Jan 2005 12:49:05 -0600 (CST)
"Arthur D. Kepner" <akepner@sgi.com> wrote:

> On Mon, 10 Jan 2005, David S. Miller wrote:
> 
> > Let's just do this all the time for this case, adding new config
> > options for stuff like this does nothing more than create confusion.
> 
> OK, you mean like the following?

Yep, patch applied.

Thanks Arthur.
