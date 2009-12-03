From: David Miller <davem@davemloft.net>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 03 Dec 2009 02:14:56 -0800 (PST)
Message-ID: <20091203.021456.40580217.davem@davemloft.net>
References: <20091202.221627.133392199.davem@davemloft.net>
	<20091202.222254.61468873.davem@davemloft.net>
	<200912031056.17103.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751953AbZLCKOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:14:50 -0500
In-Reply-To: <200912031056.17103.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 3 Dec 2009 10:56:17 +0100

> Am Donnerstag, 3. Dezember 2009 07:22:54 schrieb David Miller:
>> > I'm going to apply this patch and the USB autosuspend one too.
>> 
>> Actually, neither patch applies to net-next-2.6
>> 
>> Oliver can you respin your changes and add a proper signoff
>> to the autosuspend patch?
> 
> Hi,
> 
> here's autosuspend again.

It doesn't apply to my tree still:

davem@sunset:~/src/GIT/net-next-2.6$ git apply --check --whitespace=error-all diff
error: patch failed: drivers/net/usb/cdc_ether.c:411
error: drivers/net/usb/cdc_ether.c: patch does not apply
davem@sunset:~/src/GIT/net-next-2.6$ 
