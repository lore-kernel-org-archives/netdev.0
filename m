From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to
 disable.
Date: Fri, 31 Dec 2010 12:11:36 +0300
Message-ID: <20101231091136.GC1886@bicker>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <20101231064515.GC3733@angua.secretlab.ca>
 <4D1D7DAE.7060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>, trivial@kernel.org,
	devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-m68k@lists.linux-m68k.org,
	spi-devel-general@lists.sourceforge.net,
	linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D1D7DAE.7060504@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2010 at 10:52:30PM -0800, Justin P. Mattock wrote:
> On 12/30/2010 10:45 PM, Grant Likely wrote:
> >On Thu, Dec 30, 2010 at 03:07:51PM -0800, Justin P. Mattock wrote:
> >>The below patch fixes a typo "diable" to "disable". Please let me know if this
> >>is correct or not.
> >>
> >>Signed-off-by: Justin P. Mattock<justinmattock@gmail.com>
> >
> >applied, thanks.
> >
> >g.
> 
> ahh.. thanks.. just cleared up the left out diabled that I had
> thought I forgotten(ended up separating comments and code and
> forgot)

This is really just defensiveness and random grumbling and grumpiness on
my part, but one reason I may have missed the first patch is because
your subject lines are crap.

Wrong:  [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.

Right:  [PATCH 02/15] spi/dw_spi: Typo change diable to disable

regards,
dan carpenter
