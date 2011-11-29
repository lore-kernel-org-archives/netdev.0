From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 13:50:08 +0100 (CET)
Message-ID: <hr62jai.cb703ce1830a0044ae0461ba20654d29@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: sclark46@earthlink.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ulrich.weber@sophos.com
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>On 28.11.2011 18:14, Stephen Clark wrote:
>> On 11/24/2011 11:57 AM, kaber@trash.net wrote:
>>> The following patches contain the updated IPv6 NAT patchset forward
>>> ported
>>> to 3.2-rc3. ...
>>>
>>>
>>>    
>> Probabably a dumb question but are these patches for natting ipv6 to
>> ipv6 or ipv4 to ipv6?
>
>IPv6 to IPv6. I haven't really considered IPv6 to IPv4 yet.

Have you ever tried  ivi  The IPv6 to IPv4 gateway ?
i.e  address mapping and packet translation between IPv4 and IPv6 networks 

I made a port to resent kernel  in the begining of this year ( i think it was 2.6.36 ... ) and it seems to work.
(however there is some issues left....)

I like the idea of "ivi"  for a larger scale of translation.

/Hans

