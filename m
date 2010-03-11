From: "Philip A. Prindeville" <philipp_subx-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Thu, 11 Mar 2010 12:29:36 -0700
Message-ID: <4B9944A0.5080308@redfish-solutions.com>
References: <87my01m0zm.fsf@purkki.valot.fi>	<4B5EF5DF.2070005@lemonia.org>	<4B9942A7.40205@redfish-solutions.com> <20100311.112754.142886660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dunc-9b9L1Hpe0sBAfugRpC6u6w@public.gmane.org, kalle.valo-X3B1VOXEql0@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100311.112754.142886660.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/11/2010 12:27 PM, David Miller wrote:
> From: "Philip A. Prindeville" <philipp_subx-9z15yex7P+UJvtFkdXX2HpqQE7yCjDx5@public.gmane.org>
> Date: Thu, 11 Mar 2010 12:21:11 -0700
> 
>> And yes, there will always be misbehaving users.  They are a fact of
>> life.  That doesn't mean we should lobotomize the network.  We don't
>> have an authentication mechanism on ICMP Redirects or Source-Quench,
> 
> Which is why most networks block those packets from the outside.
> 
>> Nor is ARP authenticated.
> 
> Which is why people control who can plug into their physical
> network.
> 
> None of the things you are saying support the idea of having
> applications decide what the DSCP marking should be.


Does "decide what the DSCP marking should be" include complying to the recommendations of RFC-4594?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
