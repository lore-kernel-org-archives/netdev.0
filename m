From: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to
 disable.
Date: Fri, 31 Dec 2010 09:06:08 -0600
Message-ID: <1293807968.3085.1.camel@mulgrave.site>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	 <20101231064515.GC3733@angua.secretlab.ca> <4D1D7DAE.7060504@gmail.com>
	 <20101231091136.GC1886@bicker>  <4D1DE616.7010105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ivtv-devel-jGorlIydJmRM656bX5wj8A@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org,
	spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D1DE616.7010105-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-12-31 at 06:17 -0800, Justin P. Mattock wrote:
> On 12/31/2010 01:11 AM, Dan Carpenter wrote:
> > On Thu, Dec 30, 2010 at 10:52:30PM -0800, Justin P. Mattock wrote:
> >> On 12/30/2010 10:45 PM, Grant Likely wrote:
> >>> On Thu, Dec 30, 2010 at 03:07:51PM -0800, Justin P. Mattock wrote:
> >>>> The below patch fixes a typo "diable" to "disable". Please let me know if this
> >>>> is correct or not.
> >>>>
> >>>> Signed-off-by: Justin P. Mattock<justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >>>
> >>> applied, thanks.
> >>>
> >>> g.
> >>
> >> ahh.. thanks.. just cleared up the left out diabled that I had
> >> thought I forgotten(ended up separating comments and code and
> >> forgot)
> >
> > This is really just defensiveness and random grumbling and grumpiness on
> > my part, but one reason I may have missed the first patch is because
> > your subject lines are crap.
> >
> > Wrong:  [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
> >
> > Right:  [PATCH 02/15] spi/dw_spi: Typo change diable to disable
> >
> > regards,
> > dan carpenter
> >
> 
> alright.. so having the backlash is alright for the subject
> 
> Thanks for the pointer on this..

There is actually no specific form.  Most of us edit this part of the
subject line anyway to conform to whatever (nonuniform) conventions we
use.  I just use <component>: with no scsi or drivers prefix because the
git tree is tagged [SCSI]; others are different.

James


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
