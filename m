From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [sparse] net drivers assignment in conditional context
Date: Tue, 22 Jun 2004 14:34:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622143415.52ad9fcc@dell_ss3.pdx.osdl.net>
References: <20040622142351.1857bb9b@dell_ss3.pdx.osdl.net>
	<20040622212647.GA10589@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040622212647.GA10589@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jun 2004 22:26:47 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jun 22, 2004 at 02:23:51PM -0700, Stephen Hemminger wrote:
> > Fix several warnings from sparse about assignment used in conditional
> > context in net drivers
> 
> The patch is junk.  Fix sparse instead.

Not according to Linus.  Convince him first.
