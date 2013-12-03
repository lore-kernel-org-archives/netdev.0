From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [net v2 2/7] e1000: prevent oops when adapter is being closed
 and reset simultaneously
Date: Tue, 3 Dec 2013 10:25:47 +0800
Message-ID: <529D412B.3000001@windriver.com>
References: <1385803221-3752-3-git-send-email-jeffrey.t.kirsher@intel.com>		<529A145C.4030503@cogentembedded.com>	<529C57CE.1040801@windriver.com>	 <20131202.111237.721028511867832463.davem@davemloft.net>	 <529D3BC0.3020206@windriver.com> <1386037353.2216.19.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	<sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>,
	zhuyj <zyjzyj2000@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46392 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab3LCCZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 21:25:47 -0500
In-Reply-To: <1386037353.2216.19.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 10:22 AM, Jeff Kirsher wrote:
> On Tue, 2013-12-03 at 10:02 +0800, yzhu1 wrote:
>> On 12/03/2013 12:12 AM, David Miller wrote:
>>> From: yzhu1 <Yanjun.Zhu@windriver.com>
>>> Date: Mon, 2 Dec 2013 17:50:06 +0800
>>>
>>>> Thanks for the advice from Sergei. I made a new patch with the name
>>>> "yanjun.zhu".
>>> That's not a properly formatted real name either, it should be something
>>> like Yanjun Zhu.
>>>
>>> How do you write your name on paper when it needs to be romanized?
>>>
>>> Do you write "yanjun.zhu"?  I doubt that you do :-)
>> Hi, David
>>
>> According to the tradition and the regulations, my name should be "Zhu
>> Yanjun" or "yanjun.zhu".
>>
>> Thanks for your advice.
>> Zhu Yanjun
> So before the next time you send a kernel patch, make sure
> your .gitconfig has the following information:
>
> [user]
> 	email = yanjun.zhu@windriver.com
> 	name = Zhu Yanjun
>
OK. Thanks a lot.

Zhu Yanjun
