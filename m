From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Better namespace handling for
 /sys/class/net/bonding_masters
Date: Wed, 19 Oct 2011 18:49:35 -0400 (EDT)
Message-ID: <20111019.184935.1359396091815243878.davem@davemloft.net>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
	<20111019.000932.523712028439316177.davem@davemloft.net>
	<m18voh158i.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, htejun@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m18voh158i.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 19 Oct 2011 06:27:25 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Thu, 13 Oct 2011 00:47:46 -0700
>>
>>> Greg, Dave I'm don't know whose tree to merge this through as this code
>>> is equally device-core and networking.  I am hoping that we can get this
>>> improvement merged for 3.2.
>>
>> I'm happy to take this series into my net-next tree.
>>
>> Greg?  Any objections?
> 
> on the 13th Greg said:
> 
>> These all look fine to me, and I have no problem with them going through
>> the network tree as that will most likely be the easiest way due to any
>> potential merge issues.
>> 
>> David, feel free to add an:
>> 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

Awesome, thanks for the reminder, I'll apply these right now.
