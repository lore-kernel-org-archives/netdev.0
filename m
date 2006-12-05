From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] [IPV6] RAW: Add checksum default defines for mobility
 header.
Date: Tue, 05 Dec 2006 10:04:14 -0500
Message-ID: <45758A6E.9010209@hp.com>
References: <11653130071739-git-send-email-nakam@linux-ipv6.org> <20061205.200242.01826773.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, nakam@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:40354 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968267AbWLEPER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 10:04:17 -0500
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061205.200242.01826773.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? wrote:
>> Add checksum default defines for mobility header(MH).
>> As the result kernel's behavior is to handle MH checksum
>> as default.
> 
> I'd like to hold this on.  I need to check RFC.

That looks correct according to 3775.

-Brian
