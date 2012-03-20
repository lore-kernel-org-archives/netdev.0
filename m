From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v0 0/5] Series short description
Date: Mon, 19 Mar 2012 17:27:00 -0700
Message-ID: <4F67CED4.4000700@intel.com>
References: <20120319064719.10959.93361.stgit@jf-dev1-dcblab> <20120319.183808.976759898435189612.davem@davemloft.net> <20120319155537.79d5802c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	mst@redhat.com, chrisw@redhat.com, gregory.v.rose@intel.com,
	kvm@vger.kernel.org, sri@us.ibm.com, chealy@imsco-us.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120319155537.79d5802c@nehalam.linuxnetplumber.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/19/2012 3:55 PM, Stephen Hemminger wrote:
> On Mon, 19 Mar 2012 18:38:08 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: John Fastabend <john.r.fastabend@intel.com>
>> Date: Sun, 18 Mar 2012 23:51:45 -0700
>>
>>> This series is a follow up to this thread:
>>>
>>> http://www.spinics.net/lists/netdev/msg191360.html
>>
>> Can the interested parties please review this series?
>>
>> I'm willing to apply this right now if it looks OK, but if
>> it needs more revisions we'll have to defer.
> 
> Please don't rush this into this merge window. It needs more than
> 1 full day of review.

Dave, its probably fine to push this to 3.5 then. I can
resubmit after you close the merge window if you want? This
has been somewhat broken for SR-IOV cards for multiple
kernel releases now anyways one more wont hurt too much.

I'll work with Roopa to get the macvlan driver plugged into
the fdb ops in the meantime and maybe get DSA as well.

Thanks,
John
