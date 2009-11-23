From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net/ipv4: Move && and || to end of
 previous line
Date: Mon, 23 Nov 2009 10:31:58 -0800 (PST)
Message-ID: <20091123.103158.32535206.davem@davemloft.net>
References: <4B08D967.80003@gmail.com>
	<20091122.163112.80105623.davem@davemloft.net>
	<1259000895.16503.77.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753987AbZKWSbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 13:31:40 -0500
In-Reply-To: <1259000895.16503.77.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 23 Nov 2009 10:28:15 -0800

> On Sun, 2009-11-22 at 16:31 -0800, David Miller wrote:
>> It should be of the form:
>> 	if (x &&
>> 	    y)
>> 
>> or:
>> 	if (x && y)
>> 
>> Fix patches, rather than complaints, for existing cases where things
>> do not follow this pattern are certainly welcome.
> 
> Also collapsed some multiple tabs to single space.
> 
> Compiled tested only:

Joe, please provide a signoff so I can apply this.

Thanks.
