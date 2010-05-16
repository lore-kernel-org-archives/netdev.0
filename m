From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netns support in the kobject layer
Date: Sat, 15 May 2010 23:26:43 -0700 (PDT)
Message-ID: <20100515.232643.212422307.davem@davemloft.net>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
	<m1d3xb4239.fsf@fess.ebiederm.org>
	<20100506200404.GA21805@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, gregkh@suse.de, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org, tj@kernel.org,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, bcrl@lhnet.ca,
	serue@us.ibm.com, netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100506200404.GA21805@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Thu, 6 May 2010 13:04:04 -0700

> On Tue, May 04, 2010 at 05:35:54PM -0700, Eric W. Biederman wrote:
>> 
>> With the tagged sysfs support finally merged into Greg's tree,
>> it is time for the last little bits of work to get the kobject
>> layer and network namespaces to play together properly.
>> 
>> These patches are roughly evenly divided between network layer work
>> and sysfs layer work.  Last time this conundrum came up I believe
>> we decided that the easiest way to handle this was for Greg to carry
>> all of the patches.  David, Greg does that still make sense?
> 
> That's fine, if I get David's ack on these.

Looks good to me:

Acked-by: David S. Miller <davem@davemloft.net>
