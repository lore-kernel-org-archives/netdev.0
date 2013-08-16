From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for
 re-use
Date: Fri, 16 Aug 2013 06:52:45 -0700
Message-ID: <20130816135245.GA11236@kroah.com>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
 <87wqp9xja5.fsf@nemi.mork.no>
 <alpine.LNX.2.02.1307101425310.22696@eeeadesso>
 <0cbf7c81-182e-493c-9c28-5b78160a08f1@email.android.com>
 <alpine.LNX.2.02.1307170457450.1161@eeeadesso>
 <87bo4xx3ef.fsf@nemi.mork.no>
 <alpine.LNX.2.02.1308161534410.23935@eeeadesso>
 <20130816134907.GA10987@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130816134907.GA10987@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 16, 2013 at 06:49:07AM -0700, Greg Kroah-Hartman wrote:
> On Fri, Aug 16, 2013 at 03:39:19PM +0200, Enrico Mioso wrote:
> > Some drivers implementing NCM-like protocols, may re-use those functions, as is 
> > the case in the huawei_cdc_ncm driver.
> 
> Where is that driver at, I don't see it in the kernel tree.

And you sent it in a different email, sorry about that.

Normally you would number the patches (i.e. [1/3], and so on), so that
people know which order to apply them in, and that there really is 3
patches in the series...

thanks,

greg k-h
