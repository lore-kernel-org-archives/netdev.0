From: John Hughes <john@Calva.COM>
Subject: Re: [PATCH 1/6] X25: Use identifiers for X25 to device interface
Date: Sun, 18 Apr 2010 13:08:58 +0200
Message-ID: <4BCAE84A.2030701@Calva.COM>
References: <1271584310.6280.425.camel@ibex> <4BCAE509.9000209@Calva.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Hendry <andrew.hendry@gmail.com>, netdev@vger.kernel.org
To: John Hughes <john@Calva.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:41892 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833Ab0DRLJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 07:09:05 -0400
In-Reply-To: <4BCAE509.9000209@Calva.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Hughes wrote: 
> Shouldn't you use explicit values here?
>
> enum {
>     X25_IFACE_DATA = 0x00, /* explicit value for ABI stability */
>     ...
Oh, and is net/x25device.h suitable for inclusion from user space (xotd 
for example)?

