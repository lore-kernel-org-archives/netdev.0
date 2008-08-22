From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 05:14:11 -0400
Message-ID: <48AE8363.8090508@garzik.org>
References: <20080821185402.GD31526@susedev.qlogic.org> <20080821194802.GR7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>, Linux-Driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53804 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYHVJOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2008 05:14:16 -0400
In-Reply-To: <20080821194802.GR7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Ron Mercer wrote:
>> Hi Jeff,
>>
>> Please find our new 10Gb ethernet driver at the following site:
>>
>> ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge
>>
>> There are two files at this location:
>> qlge-aug212008.patch - A full patch that is buildable on the latest netdev/upstream kernel.
>> qlge-aug212008.tar.bz2 - A zip file of the source code at drivers/net/qlge/*
>>
>> We are targeting this driver for 2.6.28 release.  We look forward to any and all comments.
> [...]
> 
> Can you break up the patch into logical chunks and post them to netdev?
> (The message limit is 100 K.)

Actually, the limit was raised from 100k to 400k.  Given that the qlogic 
patch is 209k, it should be postable as is.

	Jeff




