From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: make IGMP flooding on active-backup bonds configurable
Date: Wed, 28 Feb 2007 20:18:14 -0500
Message-ID: <20070301011814.GB1916@gospo.rdu.redhat.com>
References: <20070228222331.GA28813@gospo.rdu.redhat.com> <200702282239.l1SMdg22017137@death.nxdomain.ibm.com> <20070301005934.GA1916@gospo.rdu.redhat.com> <200703010108.l2118x22001354@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932894AbXCABSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 20:18:20 -0500
Content-Disposition: inline
In-Reply-To: <200703010108.l2118x22001354@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 05:08:59PM -0800, Jay Vosburgh wrote:
> >
> >That sounds like a nice add-on to the existing functionality.  I can see
> >the value in something dynamic like that, but I can also see the value
> >in something static like the functionality we have.  Did you plan to
> >keep the existing functionality intact or just have it done dynamically?
> 
> 	Well, I posted the patch just a bit ago, so you can see for
> yourself, but no, it removes the existing "copy IGMP everywhere"

I see them now -- I'll check them out and make any comments there.

