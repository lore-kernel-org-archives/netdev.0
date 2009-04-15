From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Wed, 15 Apr 2009 14:21:58 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904151421070.11961@fbirervta.pbzchgretzou.qr>
References: <bug-12954-10286@http.bugzilla.kernel.org/> <20090407143509.05ab3b28.akpm@linux-foundation.org> <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se> <49DCC3A0.7050001@trash.net> <49E5CAB5.3060605@trash.net> <alpine.LSU.2.00.0904151410350.11308@fbirervta.pbzchgretzou.qr>
 <49E5CF6D.2070709@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Josefsson <gandalf@mjufs.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berni@birkenwald.de, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E5CF6D.2070709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2009-04-15 14:13, Patrick McHardy wrote:
>Jan Engelhardt wrote:
>> On Wednesday 2009-04-15 13:53, Patrick McHardy wrote:
>>   
>>> How about this patch? If the IP_NAT_RANGE_PERSISTENT flag is set
>>> on a NAT range, we ignore the destination address in the selection.
>>
>> But where do you set IP_NAT_RANGE_PERSISTENT? (It seems like a dead 
>> feature right now.)
>
>In userspace of course :)

Ah I hear the crisp sound of an upcoming iptables 1.4.4.
