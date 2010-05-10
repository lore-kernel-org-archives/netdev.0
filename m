From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 10 May 2010 02:04:39 -0700 (PDT)
Message-ID: <20100510.020439.172566219.davem@davemloft.net>
References: <4BDE9BCB.8040803@indakom.de>
	<20100503.154128.10559786.davem@davemloft.net>
	<4BE7C68F.1040403@indakom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.meissner@indakom.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898Ab0EJJEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:04:32 -0400
In-Reply-To: <4BE7C68F.1040403@indakom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Meissner <andreas.meissner@indakom.de>
Date: Mon, 10 May 2010 10:40:47 +0200

> David Miller wrote:
>> 
>> Your email client has corrupted tabs into space characters, and
>> the new code in your patch is not indented properly.
>> 
> 
> 2nd try. Indentation should be ok now, hopefully.

Please don't resubmit patches this way.  I have to now scour the
mailing list archives to get your commit message, and you also
haven't specifically signed off on this specific new patch so
I couldn't use it anyways.

Always make full, clean resubmissions of your patch, with the
original subject line and full commit message cleanly included
as in your original posting.
