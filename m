From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Add comment to make finding the priv_flags definition
 easier.
Date: Wed, 06 Aug 2003 10:30:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F313B2A.4080500@candelatech.com>
References: <3F304AC7.6070808@candelatech.com> <20030806034642.4d91641c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030806034642.4d91641c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 05 Aug 2003 17:24:39 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>This helps me, at least, remember where the definitions are at!
> 
> 
> This is silly, adding one for 'priv_flags' and not one for 'flags'.
> 
> I really don't have a taste for these "look in file foo for
> interesting stuff about bar" type comments :-)

Since they are not enums, it is hard to know where they are properly
defined.  For someone who is new to the code, I think it helps a great
deal to say where the possible values are defined.

I can add a comment for 'flags' as well, but not if no one cares anyway.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
