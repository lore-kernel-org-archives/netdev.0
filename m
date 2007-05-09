From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Wed, 09 May 2007 12:58:33 +0200
Message-ID: <4641A959.6000704@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, mikpe@it.uu.se,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.syneticon.net ([213.239.212.131]:42387 "EHLO
	mail2.syneticon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbXEIK77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 06:59:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 9 May 2007 11:35:03 +0200, Marcus Better wrote:
>> Lennert Buytenhek wrote:
>> > Does that mean that the Debian ARM people have their heads so far
>> > up their collective asses that they think that every form of change
>> > is bad and are unable to accept that some forms of change might be
>> > for the better?
>> 
>> Well, I am not one of the Debian ARM people, just a user... and I do hope the
>> EABI port becomes supported in the future! But in the meatime there is a
>> crowd of users running Debian on consumer devices like the NSLU2, and they
>> need a LE network driver.
> 
> 1) Development _should_ happen in small individually-manageable steps.
>    It's wrong to delay integration of the new IXP4xx eth driver just
>    because it's not yet LE-compatible.

True.


> 2) LE Debian/ARM users do have alternatives: they can use USB-Ethernet
>    adapters, for instance.

In case of Freecom FSG-3, that would be four USB-ethernet adapters. With 
the cost roughly half of the cost of the whole device. And all USB-ports 
occupied. Provided you don't use them for something else.

Someone could ask "why has this device four mice connected?" :) (for 
someone who doesn't work much with computers, a USB-ISDN or USB-ethernet 
adapter looks just like a mouse).


And yet another viable alternative is to use a totally different device 
which is fully supported under Linux or another system, right? :)


-- 
Tomasz Chmielewski
http://wpkg.org
