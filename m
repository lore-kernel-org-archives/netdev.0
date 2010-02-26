From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 10:40:46 -0800
Message-ID: <4B8815AE.1090909@candelatech.com>
References: <20100226165104.GB5364@lenovo>	<4B88076F.8030302@openvz.org>	<20100226100102.0d52c6e9@nehalam>	<20100226.100800.116618587.davem@davemloft.net>
	<20100226103003.097c39ec@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org, gorcunov@gmail.com,
        den@openvz.org, David Miller <davem@davemloft.net>, xemul@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20100226103003.097c39ec@nehalam>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/26/2010 10:30 AM, Stephen Hemminger wrote:
> On Fri, 26 Feb 2010 10:08:00 -0800 (PST)
> David Miller<davem@davemloft.net>  wrote:
>
>> From: Stephen Hemminger<shemminger@linux-foundation.org>
>> Date: Fri, 26 Feb 2010 10:01:02 -0800
>>
>>> TCP connections are never really bound to device. TCP routing is
>>> flexible; if packets can get through, it doesn't care.
>>
>> I think he might be talking about SO_BINDTODEVICE
>
> What application does that with TCP?

I use it..helps with using multiple interfaces on the same system,
especially when sending-to-self.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
