From: Sandeepa C S <sandeepacs@tataelxsi.co.in>
Subject: Re: Information needed on the kernel version which supports ----
Date: Tue, 15 Jan 2013 10:41:30 +0530
Message-ID: <50F4E502.2070102@tataelxsi.co.in>
References: <50F3D5FD.6090608@tataelxsi.co.in> <CAJ4ZP5T3nw+E+NP_eDZBCt=gqyiviuUoMEjm=7FuWTCDJhBEmQ@mail.gmail.com> <50F41CB1.3040909@redhat.com>
Reply-To: <sandeepacs@tataelxsi.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Balaji Foss <balajig.foss@gmail.com>, <shemminger@vyatta.com>,
	<mst@redhat.com>, <netdev@vger.kernel.org>, <stephen@redhat.com>,
	<bridge@lists.linux-foundation.org>, <shmulik.ladkani@gmail.com>,
	<davem@davemloft.net>,
	"Satyanarayana Reddy M (D&D)" <satyanarayanam@tataelxsi.co.in>
To: <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.141] ([213.199.154.141]:2522 "EHLO
	db3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750739Ab3AOFNK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 00:13:10 -0500
In-Reply-To: <50F41CB1.3040909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Even i could not find the changed files.
Could you please share if the changed files are available with you.

Thanks and Regards,
Sandeepa CS.


Vlad Yasevich wrote:
> On 01/14/2013 06:35 AM, Balaji Foss wrote:
>>   >1) On what kernel version the VLAN support for multicast groups is
>> being
>>> done
>> Its currently in the net-next tree which would become 3.8
>
> I did not see any "Applied" messages from upstream, so I doubt its in
> any tree yet.  The code is still in development.
>
> -vlad
>
>>
>>> 2)On what flavors it is supported, is it available with Debian
>>
>> If you want to test those changes right away, you will have to do a git
>> clone of the net-next repo and test those patches, else wait for the
>> distributions to package the 3.8 kernel.
>>
>>> 3)How can we get/download the supported patch files for reference.
>> you will have to make a clone of the net-next repo. For more information
>> look up tutorials on git.
>>
>> Cheers,
>>    - Balaji
>>
>> On Mon, Jan 14, 2013 at 3:25 PM, Sandeepa C S
>> <sandeepacs@tataelxsi.co.in>wrote:
>>
>>> Dear All,
>>>
>>> We are trying to add vlan support for the IGMP snooping feature in the
>>> kernel version 2.6.39
>>> But from the below thread discussion we understood that vlan support is
>>> already in the bridge.
>>> http://www.spinics.net/lists/**netdev/msg221800.html<http://www.spinics.net/lists/netdev/msg221800.html>
>>>
>>>
>>> Could you please let us know the below informations,
>>> 1) On what kernel version the VLAN support for multicast groups is
>>> being
>>> done
>>> 2)On what flavors it is supported, is it available with Debian
>>> 3)How can we get/download the supported patch files for reference.
>>>
>>> --
>>> Thanks & Regards,
>>> Sandeepa cs.
>>>
>>> Notice: The information contained in this e-mail message and/or
>>> attachments to it may contain confidential or privileged
>>> information. If
>>> you are not the intended recipient, any dissemination, use, review,
>>> distribution, printing or copying of the information contained in this
>>> e-mail message and/or attachments to it are strictly prohibited. If you
>>> have received this communication in error, please notify us by reply
>>> e-mail
>>> or telephone and immediately and permanently delete the message and any
>>> attachments. Thank you
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at
>>> http://vger.kernel.org/**majordomo-info.html<http://vger.kernel.org/majordomo-info.html>
>>>
>>>
>>
>
>
> .
>


--
 Thanks & Regards,
 Sandeepa cs.

Notice: The information contained in this e-mail message and/or attachments to it may contain confidential or privileged information. If you are not the intended recipient, any dissemination, use, review, distribution, printing or copying of the information contained in this e-mail message and/or attachments to it are strictly prohibited. If you have received this communication in error, please notify us by reply e-mail or telephone and immediately and permanently delete the message and any attachments. Thank you
