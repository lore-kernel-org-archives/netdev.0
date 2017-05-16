From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
Date: Tue, 16 May 2017 06:16:07 -0700
Message-ID: <74b898b9-7a9b-cdf4-ffeb-35f70bde3378@hartkopp.net>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
 <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
 <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
 <1d41efe1-d24f-4700-8986-0d5dc848ea23@hartkopp.net>
 <20170516080049.4fvo4hkj4e6v7r3v@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170516080049.4fvo4hkj4e6v7r3v@piout.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexandre,

On 05/16/2017 01:00 AM, Alexandre Belloni wrote:
> Hi,
>
> On 15/05/2017 at 20:51:30 -0700, Oliver Hartkopp wrote:
>> On 05/15/2017 06:50 AM, Marc Kleine-Budde wrote:
>>> Looks good, added to linux-can-next.
>>
>> Isn't this a fix for linux-can instead?
>>
>> At least it would make no sense to me to have the upgraded M_CAN driver in
>> Linux 4.12 without this fix.
>>
>
> The related suspend mode on the sama5d2 is not present in v4.12 so I
> think this can wait v4.13.
>

Agreed!

Thanks for the explanation.

Regards,
Oliver
