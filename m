From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: Submission #4  for S2io 10GbE driver
Date: Sat, 20 Mar 2004 07:42:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003101c40e91$e475d1f0$0300a8c0@S2IOtech.com>
References: <405C239B.3070804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, "'ravinandan arakali'" <ravinandan.arakali@s2io.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
In-Reply-To: <405C239B.3070804@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Agreed, will do.
Thanks for the input!
Leonid

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com] 
> Sent: Saturday, March 20, 2004 2:58 AM
> To: Christoph Hellwig
> Cc: Leonid Grossman; netdev@oss.sgi.com; 'ravinandan 
> arakali'; raghavendra.koushik@s2io.com
> Subject: Re: Submission #4 for S2io 10GbE driver
> 
> 
> Christoph Hellwig wrote:
> > On Sat, Mar 20, 2004 at 04:56:10AM -0500, Jeff Garzik wrote:
> > 
> >>applied to 2.6, thanks.
> >>
> >>Note I made the attached changes, otherwise the build would throw a
> >>bunch of errors and warnings.  Also, I merged it into 
> >>drivers/net/s2io{.c,.h,-regs.h} since there isn't a need 
> for a separate 
> >>directory for just three files.
> > 
> > 
> > There's still lots of missing statics the might want to get 
> fixed up.
> 
> Agreed.
> 
> 	Jeff
> 
> 
> 
