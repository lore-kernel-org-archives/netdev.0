From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFR] gianfar ethernet driver
Date: Mon, 2 Aug 2004 19:11:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802231112.GA890@havoc.gtf.org>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com> <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com> <1089170282.1038.80.camel@jzny.localdomain> <20040707032913.GA1822@havoc.gtf.org> <FBF8DCB8-E4D1-11D8-999F-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <AFLEMING@motorola.com>, Kumar Gala <kumar.gala@motorola.com>,
        "<netdev@oss.sgi.com>" <netdev@oss.sgi.com>, jamal <hadi@cyberus.ca>,
        "<dwmw2@infradead.org>" <dwmw2@infradead.org>,
        Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
Content-Disposition: inline
In-Reply-To: <FBF8DCB8-E4D1-11D8-999F-000393C30512@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 02, 2004 at 05:19:13PM -0500, Andy Fleming wrote:
> Here's an updated patch which fixes module support which does this:
> 
>   * More cleanup/minor bug fixes
>   * Added locking to PHY read/write wrappers
>   * Fixed module support
>   * Removed fastroute code
> 
> As before, this patch replaces the previous ones I have submitted.

the patch?  :)

	Jeff
