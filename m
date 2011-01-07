From: Iain Paton <selsinork@gmail.com>
Subject: Re: 2.6.37 vlans on bnx2 not functional, panic with tcpdump
Date: Fri, 07 Jan 2011 18:01:29 +0000
Message-ID: <4D2754F9.8050707@gmail.com>
References: <4D2634DE.2060907@gmail.com> <1294357941.21580.2.camel@HP1> <1294361206.21580.7.camel@HP1> <AANLkTi=PGPVRbS3XViskpZ0GSS8ouBcgVZYYG9EoM-Nz@mail.gmail.com> <1294422653.14051.11.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294422653.14051.11.camel@HP1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:

> The kernel has undergone major VLAN changes at this time, so there may
> be a problem depending on what stripping mode we're in.  The tg3 driver
> is having some similar problems that haven't been completely resolved
> yet.

It seems to be related to generic vlan changes, I've duplicated it on an Intel 82547L nic in a completely different system connected 
to a different switch.

So you can consider any bnx2 cause for this closed. I'll get back to the list if I can come up with any more useful info.

Thanks for your help,
Iain
