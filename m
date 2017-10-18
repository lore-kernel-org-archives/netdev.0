From: Scott Branden <scott.branden@broadcom.com>
Subject: Re: [PATCH 0/1] net: ethtool: add SmartNIC reset support
Date: Wed, 18 Oct 2017 14:59:28 -0700
Message-ID: <5d583bb0-1886-fe56-26c7-a80ba370ef2c@broadcom.com>
References: <1508342496-5047-1-git-send-email-scott.branden@broadcom.com>
 <20171018162823.GB15371@lunn.ch>
 <b9f6864a-e746-bb0d-ec8f-b85924276266@broadcom.com>
 <20171018191639.GI15371@lunn.ch>
 <e8f5b581-2613-0dda-d9cc-e826a14ee394@broadcom.com>
 <20171018213058.GD2847@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        linux-kernel@vger.kernel.org, Steve Lin <steven.lin1@broadcom.com>,
        netdev <netdev@vger.kernel.org>
To: Andy Gospodarek <andrew.gospodarek@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171018213058.GD2847@C02RW35GFVH8.dhcp.broadcom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+netdev@vger.kernel.org


On 17-10-18 02:30 PM, Andy Gospodarek wrote:
> On Wed, Oct 18, 2017 at 12:31:28PM -0700, Scott Branden wrote:
>> Hi Andrew,
>>
>>
>> On 17-10-18 12:16 PM, Andrew Lunn wrote:
>>>> Yes, there is also a management processor.
>>> O.K.
>>>
>>> Maybe it would be nice to add some more text to the commit message to
>>> make this clear. Define what an application processor is, and how it
>>> differs from a management processor. But othersize:
>> OK -will add more description to differentiate management processor vs.
>> application processor(s).
>>> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>>>
>>> I assume you have another kernel patch to actually make use of this?
>>> It is normal to post the user of a new API in the same series as the
>>> API.
>> I actually wanted to get agreement that the bit define could be added to
>> ethtool before implementing it in driver.
>> If this direction approved we'll implement in driver and submit with this
>> patch series.
> I just noticed that you did not also post this to netdev@vger.kernel.org.  I
> suspect you are more likely to get review and acceptance if that list is cc'd.
>
> I'm not positive that Linus will take networking patches off this list.
>
>>>       Andrew
>> Thanks,
>>   Scott
