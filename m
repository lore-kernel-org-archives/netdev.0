From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1q vlan updates
Date: Thu, 06 Nov 2003 13:00:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FAAB686.1090004@candelatech.com>
References: <3FA9CD0B.8000707@candelatech.com> <20031106124659.109c0d5c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031106124659.109c0d5c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 05 Nov 2003 20:24:43 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Here is a patch that is a cleaned up version of something I sent
>>a while back.  This adds the ability to query a device to see if
>>it is a vlan device by asking for the vlan's parent device.
>>One can deduce that a querried interface is not a VLAN by looking
>>at the IOCTL error code.
>>
>>Patch is against 2.4.22-pre9, compile tested and extracted from a run-time
>>tested patch.
> 
> 
> I'll push this to Marcelo for 2.4.24, thanks.
> 
> If you could cook up and test a 2.6.x version, I'll push that in
> for 2.6.1

I have yet to start using 2.6, but I'll get a test system up as soon
as 2.6.0 comes out and will send a patch shortly there-after.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
