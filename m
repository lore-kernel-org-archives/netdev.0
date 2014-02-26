From: David Miller <davem@davemloft.net>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8
 kernel
Date: Wed, 26 Feb 2014 13:58:50 -0500 (EST)
Message-ID: <20140226.135850.1623740440287707032.davem@davemloft.net>
References: <6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
	<20140226.115831.255949929805078536.davem@davemloft.net>
	<CANEJEGtJfUsond3kowuQ24JbLdE71CGEtX4BgMDKyG2AFuiniw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, inky.yoo@samsung.com, netdev@vger.kernel.org
To: grundler@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaBZS6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:58:52 -0500
In-Reply-To: <CANEJEGtJfUsond3kowuQ24JbLdE71CGEtX4BgMDKyG2AFuiniw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@google.com>
Date: Wed, 26 Feb 2014 09:19:29 -0800

> On Wed, Feb 26, 2014 at 8:58 AM, David Miller <davem@davemloft.net> wrote:
>> It is mysterious to me when a driver author behaves in such a way that
>> they seem to want their driver to work on fewer instances of their
>> hardware rather than support more of them.
> 
> Well, we don't know the whole story. Samsung asked for a different USB
> Vendor/Device ID and it's possible a few other things got change along
> the way.
> 
> If this HW/FW was clearly production and I had a patch that made it
> work, then we'd be in the situation you are describing.

Ok, fair enough.
