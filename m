From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [patch 01/16]  __FUNCTION__ string concatenation
Date: Thu, 2 Sep 2004 17:28:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902152807.GA1894@stro.at>
References: <200409021302.22823.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <200409021302.22823.margitsw@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Margit Schubert-While wrote:

> On Thu, 02 Sep 2004, Maximilian scribeth:
> > I don't have the hardware to do a run-time check.
> > It should not pose any problems though.
> 
> Oh, I think we can safely say that, especially as TRACE
> is nowhere referenced  ;-)
> (And therefore the patch is unnecessary)

yup nice hint it was used:
drivers/net/wireless/prism54/islpci_hotplug.c:  /* TRACE(DRV_NAME); */

will resent patch that removes both.

--
maks
