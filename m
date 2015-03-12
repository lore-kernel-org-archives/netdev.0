From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/3] EEE support for mv88e6172
Date: Thu, 12 Mar 2015 01:46:00 -0700
Message-ID: <55015248.9090103@roeck-us.net>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch> <20150311.165931.2141833376642325076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:46382 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753337AbbCLIqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 04:46:03 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YVykk-003Mrg-KV
	for netdev@vger.kernel.org; Thu, 12 Mar 2015 08:46:02 +0000
In-Reply-To: <20150311.165931.2141833376642325076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 01:59 PM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Tue, 10 Mar 2015 23:05:56 +0100
>
>> This patchset contains two cleanups and then adds EEE support
>> to the mv88e6172, using the base provided by Guenter Roeck
>>
>> Tested on a WRT1900AC with mv88e6172 and DIR665 with mv88e6171.
>
> This series does not apply cleanly to net-next.
>
> I really want to discourage you posting patches against trees other
> that net and net-next like this, without CLEARLY marking in the
> Subject lines that this patch series is special and that I should
> not try to review and apply it at all.
>

Andrew,

I see two options: I can submit my entire series of HW bridging
patches for mv88e6xxx, or I submit the introductory patches of that
series (the ones refactoring the code to prepare for HW bridging)
plus your (rebased) patches on top of it.

What do you think ?

Thanks,
Guenter
