From: Elina Pasheva <epasheva@sierrawireless.com>
Subject: RE: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c
 driver
Date: Sat, 1 May 2010 22:53:52 -0700
Message-ID: <8F90F944E50427428C60E12A34A309D22FC801D84A@carmd-exchmb01.sierrawireless.local>
References: <1272497304.8835.2.camel@Linuxdev4-laptop>,<20100501.180829.139101312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "dbrownell@users.sourceforge.net" <dbrownell@users.sourceforge.net>,
	Rory Filer <rfiler@SierraWireless.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from carmd-sa01.sierrawireless.com ([208.81.121.45]:57806 "EHLO
	carmd-sa01.sierrawireless.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751756Ab0EBF5p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 May 2010 01:57:45 -0400
In-Reply-To: <20100501.180829.139101312.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Saturday, May 01, 2010 6:08 PM David Miller wrote:

>>From: Elina Pasheva <epasheva@sierrawireless.com>
>>Date: Wed, 28 Apr 2010 16:28:24 -0700

>> Subject: [PATCH 1/1] net/usb: initiate sync sequence in sierra_net.c driver
>> From: Elina Pasheva <epasheva@sierrawireless.com>
>>
>> The following patch adds the initiation of the sync sequence to
>> "sierra_net_bind()". If this step is omitted, the modem will never sync up
>> with the host and it will not be possible to establish a data connection.
>> This is a high priority patch.
>>
>> This patch has been checked against net-2.6 tree.
>> Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
>> Signed-off-by: Rory Filer <rfiler@sierrawireless.com>
>> Tested-by: Elina Pasheva <epasheva@sierrawireless.com>

>Applied.

Thank you very much, David!
Elina


