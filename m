From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] [sparse] net drivers assignment in conditional context
Date: Tue, 22 Jun 2004 22:26:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622212647.GA10589@infradead.org>
References: <20040622142351.1857bb9b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040622142351.1857bb9b@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 22, 2004 at 02:23:51PM -0700, Stephen Hemminger wrote:
> Fix several warnings from sparse about assignment used in conditional
> context in net drivers

The patch is junk.  Fix sparse instead.
