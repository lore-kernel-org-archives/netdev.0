From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Submission #4  for S2io 10GbE driver
Date: Sat, 20 Mar 2004 10:48:14 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040320104814.A22674@infradead.org>
References: <001001c40e34$d2c3c4b0$0300a8c0@S2IOtech.com> <405C153A.2020809@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leonid Grossman <leonid.grossman@s2io.com>, netdev@oss.sgi.com,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <405C153A.2020809@pobox.com>; from jgarzik@pobox.com on Sat, Mar 20, 2004 at 04:56:10AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 20, 2004 at 04:56:10AM -0500, Jeff Garzik wrote:
> applied to 2.6, thanks.
> 
> Note I made the attached changes, otherwise the build would throw a 
> bunch of errors and warnings.  Also, I merged it into 
> drivers/net/s2io{.c,.h,-regs.h} since there isn't a need for a separate 
> directory for just three files.

There's still lots of missing statics the might want to get fixed up.
