From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2009-06-08
Date: Mon, 08 Jun 2009 23:47:01 -0700 (PDT)
Message-ID: <20090608.234701.51739911.davem@davemloft.net>
References: <1244466304.24950.4.camel@localhost.localdomain>
	<20090608.142440.129404475.davem@davemloft.net>
	<1244526163.3068.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756197AbZFIGq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 02:46:59 -0400
In-Reply-To: <1244526163.3068.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 09 Jun 2009 07:42:43 +0200

> Hi Dave,
> 
>> > these are the Bluetooth patches for the 2.6.31 kernel release. They are
>> > mostly cleanups and removal of dead/unused code. However we do integrate
>> > with the re-written RFKILL subsystem now. This gives us proper soft-kill
>> > support for internal and external devices.
>> 
>> Where is the attached patch we talked about the other week
>> so that your pull requests get tracked in patchwork?
> 
> I thought you wanted it only for the net-2.6 pull requests and not for
> the net-next-2.6 ones. Do you want them for both?

If the diff is small enough to fit on the list, do them for both.

If it's a lot of new stuff and huge, you can pass on it.
