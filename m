From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Rules and groups
Date: Wed, 9 Aug 2006 15:25:47 +0200
Message-ID: <20060809132547.GZ14627@postel.suug.ch>
References: <20060809080139.GA19555@souterrain.chygwyn.com> <20060809.010125.78708459.davem@davemloft.net> <20060809100326.GA23935@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42904 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750771AbWHINZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 09:25:26 -0400
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20060809100326.GA23935@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Whitehouse <steve@chygwyn.com> 2006-08-09 11:03
> On Wed, Aug 09, 2006 at 01:01:25AM -0700, David Miller wrote:
> > From: Steven Whitehouse <steve@chygwyn.com>
> > Date: Wed, 9 Aug 2006 09:01:39 +0100
> > 
> > > Is there anything to stop me using RTNLGRP_NOP3 for that? (suitable
> > > renamed of course!) So far as I can see its never been assigned to
> > > anything else...
> > 
> > I have no objection to you using it.
> >
> Excellent. Please find attached my attempt at doing the conversion to the
> generic rules code. It appears to work ok for me. You can also pull this
> patch from the decnet git tree at:

Looks good to me.
