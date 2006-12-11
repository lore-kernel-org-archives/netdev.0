From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH  v3 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Mon, 11 Dec 2006 11:49:53 -0800
Message-ID: <457DB661.6060102@chelsio.com>
References: <20061210223244.27166.36192.stgit@dell3.ogc.int>	 <adafybn2i7n.fsf@cisco.com> <1165851389.13419.3.camel@stevo-desktop> <457DB08C.8070709@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	Felix Marti <felix@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27392 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763042AbWLKTvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 14:51:03 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <457DB08C.8070709@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> Steve Wise wrote:
>> On Sun, 2006-12-10 at 20:02 -0800, Roland Dreier wrote:
>>  
>>> I haven't seen any evidence of the corresponding ethernet NIC driver
>>> being merged for 2.6.20 (which is a prerequisite, right).
>>>
>>> What's the status of that?
>>>
>>>     
>>
>> It is on its third or fourth round of review.  The last driver posted on
>> 12/7, was merged up to linus's latest tree probably as of 12/7.  I know
>> the comments set it was against 2.6.19, but it was really linus's
>> latest.
>>
>> Divy, can you expand on this?
>>   
> Steve, the patch for the Chelsio T3 driver was postered against 
> Linus'tree indeed.
>
> -bash-3.00$ cat .git/refs/heads/origin
> 0215ffb08ce99e2bb59eca114a99499a4d06e704
I meant
-bash-3.00$ cat .git/refs/heads/master
9eba2b0ba067ce9745e575e5ea2e97a5d7d61bef

>
> It incorporated Stephen's feedback.
> The comments I received since then concern minor coding style glitches.
> I will fix them, the driver functionality should remain unchanged 
> however.
>
> Cheers,
> Divy
>
>
>>
>> Steve.
>>
>>   
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

