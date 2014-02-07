From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Fri, 7 Feb 2014 06:48:54 +0100
Message-ID: <20140207054852.GA4954@netboy>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
 <20140204092939.GA9862@netboy>
 <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
 <1391527464.7871.15.camel@e37108.spectralink.com>
 <20140204154323.GA2815@netboy>
 <1391586016.7871.23.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?B?U/hyZW5zZW4s?= Stefan
	<Stefan.Sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:47665 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbaBGFtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 00:49:07 -0500
Received: by mail-ee0-f51.google.com with SMTP id b57so1297489eek.10
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 21:49:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1391586016.7871.23.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 05, 2014 at 07:40:17AM +0000, S=F8rensen, Stefan wrote:
>=20
> Will all PTP clocks be associated with an ethernet device? If not,
> wouldn't a PTP ioctl be better than ethtool?=20

Hm, maybe. I don't have a strong preference. I'll try and put together
an idea of how the ioctl might look like.

Thanks,
Richard
