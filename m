From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Fw: [Kernel-janitors] old ioctl definitions in 2.5
Date: Tue, 16 Sep 2003 10:33:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309161733.h8GHXdTJ013890@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: "David S. Miller" <davem@redhat.com>, rddunlap@osdl.org,
   netdev@oss.sgi.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Tue, 16 Sep 2003 16:31:48 +0300." <200309161631.48653.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>On Tuesday 16 September 2003 04:11 am, Jay Vosburgh wrote:
>> >On Mon, 15 Sep 2003 16:57:26 -0700
>> >
>> >Jay Vosburgh <fubar@us.ibm.com> wrote:
>> >>      My only concern is a matter of timing; we're right at the
>> >> end of synchronizing the 2.4 and 2.6 bonding sources.  Once
>> >> that's settled (hopefully in a few days, the last patch set for
>> >> 2.4 came in this morning), then removing them from that header
>> >> and the bonding code should be fine.
>> >
>> >No problem.  Just push the change to Jeff then after you're
>> >done merging stuff around, ok?
>>
>>         Will do.
>
>I'm on the verge of finishing my cleanup set re-do. Now that Amir sent 
>all the synching stuff, I could put that one in as well, and it would 
>fit on both 2.4 and 2.6.

	I was going to add it on to the end of the clean up set, but
if you want to do it, go ahead.  Nobody seems to have objected to
removing the _OLD stuff, which I view as a good thing.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
