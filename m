From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: Steps for netdev-2.6 inclusion?
Date: Thu, 06 Jan 2005 10:10:50 -0600
Message-ID: <41DD630A.1030604@linux.intel.com>
References: <41AE7143.80505@linux.intel.com> <41C88183.3020906@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41C88183.3020906@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> James Ketrenos wrote:
>
>>
>> Ok, its been a long time coming, but it appears the ipw* wireless 
>> drivers are to the point where being more proactive at getting them 
>> into the kernel is appropriate (at least based on the frequency of 
>> emails I'm getting of 'why isn't this in mainline?')
>>
>> So, what would be the set of steps required to get a version in the 
>> queue for inclusion?
>
>
> Any updates?  Where do we stand with this?

Sorry -- we had some fires to put out, and then Christmas kicked in :)

We're rolling in a couple fixes into the 2200 driver this week for 
ad-hoc mode and will then send out the patches to this list.

Thanks,
James

>
> I would suggest sending a patch for each driver, diff'd against -mm 
> (which auto-includes my netdev-2.6 and wireless-2.6 queues).
>
>     Jeff
>
>
>
