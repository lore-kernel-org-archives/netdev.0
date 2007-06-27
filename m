From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 13:44:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706271340240.6919@bender.nucleusys.com>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Peter Korsgaard <jacmet@sunsite.dk>, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.estnet.bg ([89.253.152.15]:2807 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753627AbXF0LSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 07:18:37 -0400
In-Reply-To: <46821E80.8080105@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Jun 2007, Jeff Garzik wrote:

> Peter Korsgaard wrote:
>> Questions regarding the USB network drivers should now go to netdev.
>> 
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
>> ---
>>  MAINTAINERS |   13 +++++--------
>>  1 file changed, 5 insertions(+), 8 deletions(-)
>> 
>> Index: linux-2.6.22-rc6/MAINTAINERS
>> ===================================================================
>> --- linux-2.6.22-rc6.orig/MAINTAINERS
>> +++ linux-2.6.22-rc6/MAINTAINERS
>> @@ -3610,15 +3610,14 @@
>>  USB CDC ETHERNET DRIVER
>>  P:	Greg Kroah-Hartman
>>  M:	greg@kroah.com
>> -L:	linux-usb-users@lists.sourceforge.net
>> -L:	linux-usb-devel@lists.sourceforge.net
>> +L:	netdev@vger.kernel.org
>>  S:	Maintained
>>  W:	http://www.kroah.com/linux-usb/
>>   USB DAVICOM DM9601 DRIVER
>>  P:	Peter Korsgaard
>>  M:	jacmet@sunsite.dk
>> -L:	linux-usb-devel@lists.sourceforge.net
>> +L:	netdev@vger.kernel.org
>>  W:	http://www.linux-usb.org/usbnet
>>  S:	Maintained
>>  @@ -3702,8 +3701,7 @@
>>  USB PEGASUS DRIVER
>>  P:	Petko Manolov
>>  M:	petkan@users.sourceforge.net
>> -L:	linux-usb-users@lists.sourceforge.net
>> -L:	linux-usb-devel@lists.sourceforge.net
>> +L:	netdev@vger.kernel.org
>>  W:	http://pegasus2.sourceforge.net/
>>  S:	Maintained
>>  @@ -3717,8 +3715,7 @@
>>  USB RTL8150 DRIVER
>>  P:	Petko Manolov
>>  M:	petkan@users.sourceforge.net
>> -L:	linux-usb-users@lists.sourceforge.net
>> -L:	linux-usb-devel@lists.sourceforge.net
>> +L:	netdev@vger.kernel.org
>>  W:	http://pegasus2.sourceforge.net/
>>  S:	Maintained
>>  @@ -3829,7 +3826,7 @@
>>  USB "USBNET" DRIVER FRAMEWORK
>>  P:	David Brownell
>>  M:	dbrownell@users.sourceforge.net
>> -L:	linux-usb-devel@lists.sourceforge.net
>> +L:	netdev@vger.kernel.org
>>  W:	http://www.linux-usb.org/usbnet
>>  S:	Maintained
>
> Quite true, but for courtesy's sake you should keep the relevant 
> maintainers in the loop, and get their ACKs, when you start changing 
> their MAINTAINERS entries.
>
> 	Jeff

Well, with these drivers there are as many USB related issues as there are 
network ones.  I'd rather have both lists in the file.  Linux-usb-users 
should probably go away, but i guess Greg has the final word.


 		Petko
