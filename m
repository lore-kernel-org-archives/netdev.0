From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 11/11] netlink: add documentation for memory mapped I/O
Date: Thu, 23 Aug 2012 00:19:56 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208230016540.5113@stinky-local.trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
 <1345443532-3707-12-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208201224430.8114@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Florian.Westphal@Sophos.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1208201224430.8114@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2012, Jan Engelhardt wrote:

> On Monday 2012-08-20 08:18, Patrick McHardy wrote:
>> +
>> +RX and TX rings
>> +----------------
>> +
>> +Each ring contains a number of continous memory blocks, containing frames of
>> +fixed size dependant on the parameters used for ring setup.
>
> dependent
> [...]

All fixed, thanks.
