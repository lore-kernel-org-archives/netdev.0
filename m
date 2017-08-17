From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V6 21/21] net-next/hinic: Add netpoll
Date: Thu, 17 Aug 2017 15:59:30 +0300
Message-ID: <42488255-13d8-c2c3-cf5c-b2581293a6b7@huawei.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
 <cae481edc7c9217cc61dbeb1f7eb642ba7a9dbfc.1502972069.git.aviad.krawczyk@huawei.com>
 <183ebd9b-4468-1adb-b366-a068aec907ae@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <183ebd9b-4468-1adb-b366-a068aec907ae@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Will be fixed in V7

Thanks

On 8/17/2017 3:57 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/17/2017 03:25 PM, Aviad Krawczyk wrote:
> 
>> Add more netdev operation - netpoll.
>>
>> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
>> Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
>> ---
>>   MAINTAINERS                                    |  7 +++++++
>>   drivers/net/ethernet/huawei/hinic/hinic_main.c | 20 ++++++++++++++++++++
>>   2 files changed, 27 insertions(+)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 0e967b3..8f9ea9b 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -6240,6 +6240,13 @@ L:    linux-input@vger.kernel.org
>>   S:    Maintained
>>   F:    drivers/input/touchscreen/htcpen.c
>>   +HUAWEI ETHERNET DRIVER
>> +M:    Aviad Krawczyk <aviad.krawczyk@huawei.com>
>> +L:    netdev@vger.kernel.org
>> +S:    Supported
>> +F:    Documentation/networking/hinic.txt
>> +F:    drivers/net/ethernet/huawei/hinic/
>> +
> 
>    Sorry for not asking this question before: how is the new MAINTAINERS record related to the netpoll support? This should be in a separate patch.
> 
> [...]
> 
> MBR, Sergei
> 
> .
> 
