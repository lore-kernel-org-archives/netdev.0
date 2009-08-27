From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] MAINTAINERS: update information for sfc network
 driver
Date: Wed, 26 Aug 2009 18:04:45 -0700 (PDT)
Message-ID: <20090826.180445.102441324.davem@davemloft.net>
References: <1251310744.27345.21.camel@achroite>
	<1251312467.13026.22.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435AbZH0BEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:04:32 -0400
In-Reply-To: <1251312467.13026.22.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 26 Aug 2009 11:47:47 -0700

> On Wed, 2009-08-26 at 19:19 +0100, Ben Hutchings wrote:
>> Update the current maintainers and add our email addresses.  Robert
>> Stonehouse has moved on to other projects.
>> 
>> Move the linux-net-drivers alias to the top since it should always
>> reach the current maintainers at Solarflare.  Add netdev as the
>> relevant mailing list.
> []
>> +M:	linux-net-drivers@solarflare.com (alias for current maintainers)
> 
> Hi Ben
> 
> This form: "M:	bare address (extra stuff)" doesn't work
> with the get_maintainers script.
> 
> Can you please use something like this instead?
> 
> M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> 
> Perhaps this diff below.

Joe's version seems based upon reasonable requests, so I've
applied his diff.

Thanks.
