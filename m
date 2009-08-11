From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] sky2: driver update
Date: Mon, 10 Aug 2009 17:52:05 -0700 (PDT)
Message-ID: <20090810.175205.151246332.davem@davemloft.net>
References: <20090806161213.148382653@vyatta.com>
	<20090809.210943.256633746.davem@davemloft.net>
	<20090810084822.2df65a12@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751800AbZHKAv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 20:51:56 -0400
In-Reply-To: <20090810084822.2df65a12@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 10 Aug 2009 08:48:22 -0700

> On Sun, 09 Aug 2009 21:09:43 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 06 Aug 2009 09:12:13 -0700
>> 
>> > This undoes the prematurely committed sky2 transmit logic changes
>> > and applies Mike's later changes.
>> > Here is a corrected patch stream please apply this to 2.6.31-rc5
>> 
>> I have to pass on this set, too many problems:
>> 
>> 1) You didn't provide explicit "From: " lines for patches where
>>    you were not the author Stephen.  I could guess from the
>>    Signoff lines but I'd rather not.
> 
> What is the mechanics for this, does patchwork accept From:
> lines in message body?

Yes, this is exactly how it works, git format-patch will even
generate these for you :-)
