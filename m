From: Elina Pasheva <epasheva@sierrawireless.com>
Subject: RE: question re: net-2.6 and net-next-2.6 trees re: patch submission
Date: Fri, 30 Apr 2010 22:01:08 -0700
Message-ID: <8F90F944E50427428C60E12A34A309D22FC801D844@carmd-exchmb01.sierrawireless.local>
References: <1272675194.21110.9.camel@Linuxdev3>,<20100430.190145.45137187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dbrownell@users.sourceforge.net" <dbrownell@users.sourceforge.net>,
	Rory Filer <rfiler@SierraWireless.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from carmd-sa01.sierrawireless.com ([208.81.121.45]:52657 "EHLO
	carmd-sa01.sierrawireless.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750888Ab0EAFBL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 May 2010 01:01:11 -0400
In-Reply-To: <20100430.190145.45137187.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 4/30/2010 7:05 PM David Miller wrote:

>>From: Elina Pasheva <epasheva@sierrawireless.com>
>>Date: Fri, 30 Apr 2010 17:53:14 -0700

>> If I submit a new driver to net-2.6 tree (e.g. sierra_net driver that
>> was applied to net-2.6 tree) where do I submit subsequent patches for
>> that driver - net-2.6 tree or net-next-2.6 tree?

>It depends upon the severity of the fix.

>At this stage in the game on the most serious fixes are going
>in, fixes for things that cause crashes and the like.  However
>since a new driver we might be a little bit more lenient since
>changes to a new driver can harm less people.

Thank you, David.

Would you please apply
[PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c driver
 which is a very serious fix and affects the driver's functionality.
Sorry, it was my bad.

I tested this patch  with USB 306.

Thanks,
Elina

