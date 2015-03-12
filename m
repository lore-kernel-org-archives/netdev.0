From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/3] EEE support for mv88e6172
Date: Thu, 12 Mar 2015 06:41:31 -0700
Message-ID: <5501978B.10308@roeck-us.net>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch> <20150311.165931.2141833376642325076.davem@davemloft.net> <55015248.9090103@roeck-us.net> <20150312121416.GF14112@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:43287 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbbCLNlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 09:41:36 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YW3Mk-002GuD-M9
	for netdev@vger.kernel.org; Thu, 12 Mar 2015 13:41:34 +0000
In-Reply-To: <20150312121416.GF14112@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2015 05:14 AM, Andrew Lunn wrote:
> On Thu, Mar 12, 2015 at 01:46:00AM -0700, Guenter Roeck wrote:
>> On 03/11/2015 01:59 PM, David Miller wrote:
>>> From: Andrew Lunn <andrew@lunn.ch>
>>> Date: Tue, 10 Mar 2015 23:05:56 +0100
>>>
>>>> This patchset contains two cleanups and then adds EEE support
>>>> to the mv88e6172, using the base provided by Guenter Roeck
>>>>
>>>> Tested on a WRT1900AC with mv88e6172 and DIR665 with mv88e6171.
>>>
>>> This series does not apply cleanly to net-next.
>>>
>>> I really want to discourage you posting patches against trees other
>>> that net and net-next like this, without CLEARLY marking in the
>>> Subject lines that this patch series is special and that I should
>>> not try to review and apply it at all.
>>>
>>
>> Andrew,
>
> Yes, i messed up :-(
>
>> I see two options: I can submit my entire series of HW bridging
>> patches for mv88e6xxx, or I submit the introductory patches of that
>> series (the ones refactoring the code to prepare for HW bridging)
>> plus your (rebased) patches on top of it.
>>
>> What do you think ?
>
> There is no rush with these patches. When you are ready, post the
> whole hardware bridge patches for review. Once they are accepted, i
> will try again with the EEE patches for mv88e6171.
>

Ok.

Did you have time to test the bridging code ?

Thanks,
Guenter
