From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Thu, 22 Jun 2006 13:41:23 -0700
Message-ID: <20060622204123.GB14445@kroah.com>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34717 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1161329AbWFVUoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 16:44:34 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 08:12:24AM -0400, Luis R. Rodriguez wrote:
> I know we recently moved WE to netlink but I figured celebrating the
> happy marriage of Mr. sysfs and Mrs. configfs on 2.6.16 by giving them
> offspring would be nice and more appropriate.

What, right after deciding one thing, you want to switch it all over to
something completly different?  How about giving netlink a chance and
wait to see how well (or not) that works out, so that you will have more
insight and history into any problems that you had so as to best address
them in the future.

thanks,

greg k-h
