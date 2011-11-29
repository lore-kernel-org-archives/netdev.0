From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 15:05:20 +0100
Message-ID: <4ED4E6A0.5010508@trash.net>
References: <hr62jai.cb703ce1830a0044ae0461ba20654d29@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ulrich.weber@sophos.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <hr62jai.cb703ce1830a0044ae0461ba20654d29@obelix.schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/2011 01:50 PM, Hans Schillstrom wrote:
>>> Probabably a dumb question but are these patches for natting ipv6 to
>>> ipv6 or ipv4 to ipv6?
>> IPv6 to IPv6. I haven't really considered IPv6 to IPv4 yet.
> Have you ever tried  ivi  The IPv6 to IPv4 gateway ?
> i.e  address mapping and packet translation between IPv4 and IPv6 networks

No, I'm currently looking at stateless IPv6 NAT mechanisms.

> I made a port to resent kernel  in the begining of this year ( i think it was 2.6.36 ... ) and it seems to work.
> (however there is some issues left....)
>
> I like the idea of "ivi"  for a larger scale of translation.

Do you have a pointer to your port?
