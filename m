From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/5] Better namespace handling for /sys/class/net/bonding_masters
Date: Wed, 19 Oct 2011 06:27:25 -0700
Message-ID: <m18voh158i.fsf@fess.ebiederm.org>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
	<20111019.000932.523712028439316177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, htejun@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019.000932.523712028439316177.davem@davemloft.net> (David
	Miller's message of "Wed, 19 Oct 2011 00:09:32 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 13 Oct 2011 00:47:46 -0700
>
>> Greg, Dave I'm don't know whose tree to merge this through as this code
>> is equally device-core and networking.  I am hoping that we can get this
>> improvement merged for 3.2.
>
> I'm happy to take this series into my net-next tree.
>
> Greg?  Any objections?

on the 13th Greg said:

> These all look fine to me, and I have no problem with them going through
> the network tree as that will most likely be the easiest way due to any
> potential merge issues.
> 
> David, feel free to add an:
> 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> to these patches and take them through your tree if that is ok with you.
> If not, I can also always take them through mine, it's your choice.

Eric
