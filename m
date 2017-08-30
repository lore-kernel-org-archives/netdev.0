From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Signed-off-by missing for commit in the net-next
 tree
Date: Wed, 30 Aug 2017 10:52:08 -0700 (PDT)
Message-ID: <20170830.105208.866936923406230960.davem@davemloft.net>
References: <20170831025131.56d2cf92@canb.auug.org.au>
        <32dc9201-c7a2-2cf0-e8a1-1c735b8784ee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
        linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: dsahern@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <32dc9201-c7a2-2cf0-e8a1-1c735b8784ee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Ahern <dsahern@gmail.com>
Date: Wed, 30 Aug 2017 10:53:48 -0600

> On 8/30/17 10:51 AM, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Commit
>> 
>>   1b70d792cf67 ("ipv6: Use rt6i_idev index for echo replies to a local address")
>> 
>> is missing a Signed-off-by from its author.
>> 
> 
> Eric pointed this out last night. The commit message copied output from
> a command that contained '---' so git ignored the remainder of the message.

Yes, it unfortunately got clipped off by GIT due to how the
commit message was written. :(
