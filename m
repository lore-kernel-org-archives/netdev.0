From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: via-velocity: printk of dev->name before name has been allocated
Date: Sun, 22 Feb 2009 11:44:02 +0100
Message-ID: <49A12C72.3070309@computer.org>
References: <49A04E4B.7080207@computer.org>	<20090221.235152.144560236.davem@davemloft.net>	<49A11019.6050400@computer.org> <20090222.023343.109308607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:23527 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753221AbZBVKpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 05:45:14 -0500
In-Reply-To: <20090222.023343.109308607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jan Ceuleers <jan.ceuleers@computer.org>
> Date: Sun, 22 Feb 2009 09:43:05 +0100
> 
>> As I wrote I did look at current git net-2.6 and thought the issue
>> was still there. That was based on looking at the code though; I
>> can't run a current kernel on that machine.
>>
>> You guys ar going to have to get better at communicating with your
>> user base...
> 
> You're the one who didn't mention that you looked at the current
> code, that changes everything :)

I did actually, you're the one who didn't read what I wrote.

Quoting from my original email:

"This is with the following kernel version:

Linux fe2 2.6.22-16-generic #1 SMP Mon Jan 26 00:07:52 GMT 2009 i686 
GNU/Linux

which is quite "old", but when I looked at current git net-2.6 I think 
that this problem is still there."

