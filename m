From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth patches for 2.6.21-rc7
Date: Wed, 25 Apr 2007 16:15:51 -0700 (PDT)
Message-ID: <20070425.161551.27783108.davem@davemloft.net>
References: <1177542355.14980.46.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	gregkh@suse.de, kay.sievers@vrfy.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754509AbXDYXPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:15:45 -0400
In-Reply-To: <1177542355.14980.46.camel@aeonflux.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 26 Apr 2007 01:05:55 +0200

> I have two last minute patches before the final 2.6.21 kernel hits the
> streets. One is a kernel memory leak that has been classified as
> security issue. The second one is a sysfs fix to correct a wrong use of
> class and bus devices.

I don't think this one will make it as Linus is very eager
to get the release out at this point :-)

If it doesn't, I will make sure to push it into the -stable
branch, so no worries.
