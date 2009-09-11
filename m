From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 2/2] ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB
 interface
Date: Fri, 11 Sep 2009 14:07:21 +0200
Message-ID: <4AAA3D79.8090401@hartkopp.net>
References: <20090911105449.7815.65368.stgit@localhost.localdomain> <20090911105455.7815.12354.stgit@localhost.localdomain> <4AAA362F.30806@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sebastian Haas <haas@ems-wuensche.com>, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, greg@kroah.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:46450 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbZIKMHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 08:07:33 -0400
In-Reply-To: <4AAA362F.30806@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Hi Sebastian,
> 
> Sebastian Haas wrote:
>> This patch adds support for one channel CAN/USB interace CPC-USB/ARM7 from
>> EMS Dr. Thomas Wuensche (http://www.ems-wuensche.com).
>>
>> Signed-off-by: Sebastian Haas <haas@ems-wuensche.com>
> 
> we reviewed the driver already on the Socket-CAN ML and it's OK from the
> Socket-CAN point of view. 

Ack.

> I will do a quick (re-)check beginning of next
> week. I would be nice to have this patch also reviewed by some Linux USB
> experts. Therefore I suggest sending it to the relevant Linux-USB
> mailing list as well.

When there is feedback that would cause any changes (and a second posting), i
would suggest to put the driver under

drivers/net/can/usb/ems_usb.c

Regards,
Oliver

