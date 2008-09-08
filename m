From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver (Resend2)
Date: Mon, 08 Sep 2008 12:06:27 -0400
Message-ID: <48C54D83.3020609@pobox.com>
References: <48B12183.50601@cooldavid.org> <20080825015014.M78106@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Content-Transfer-Encoding: 7bit
Cc: Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>,
	netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbYIHQGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 12:06:37 -0400
In-Reply-To: <20080825015014.M78106@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guo-Fu Tseng wrote:
> On Sun, 24 Aug 2008 16:53:23 +0800, Guo-Fu Tseng wrote
>> Dear Jeff:
>>
>> New patch for JMicron Gigabit Ethernet driver has been made again.
>>
>> Modified according to Stephen's suggestion:
>> 	* Correctly use of __u32, and u32 data type.
>> 	* Move DEVICE ID from global include/linux/pci_ids.h to jme.h
>>
>> The patch is also available at:
>> http://cooldavid.org/download/jme.netdev-2.6.20080824.2.patch
>>
>> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
>> ---
> Hi Jeff:
> 
> I've found that after some modification, ACPI resume will fail,
> although I seems to found the cause and fixed it. But I decided
> to perform more test after the modification. After the test I'll
> send another patch. Please hold this patch for a while.
> 
> Sorry for the noise that have been made.

Any updates?

The last version of the driver I saw was OK for merging, in my opinion.

	Jeff




