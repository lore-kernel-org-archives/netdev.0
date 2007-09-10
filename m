From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac.c: De-typedef, de-volatile, de-etc...
Date: Mon, 10 Sep 2007 17:58:08 +0100
Message-ID: <20070910165808.GA7501@linux-mips.org>
References: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0709101310030.25038@blysk.ds.pg.gda.pl>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 01:20:38PM +0100, Maciej W. Rozycki wrote:

>  Remove typedefs, volatiles and convert kmalloc()/memset() pairs to
> kcalloc().  Also reformat the surrounding clutter.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  Per your request, Andrew, a while ago.  It builds, runs, passes 
> checkpatch.pl and sparse.  No semantic changes.

One step closer to sanity for this driver.  So it's got my ACK.

  Ralf
