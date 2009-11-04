From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [Bugme-new] [Bug 14427] New: ipv6 forward cause strange route
Date: Wed, 4 Nov 2009 10:01:15 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0911040959540.10606@netcore.fi>
References: <bug-14427-10286@http.bugzilla.kernel.org/> <20091102223237.c0102f19.akpm@linux-foundation.org> <4AF00EA0.7030407@linux-ipv6.org> <4AF011A6.1070903@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@linux-foundation.org>, green@msu.ru,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54828 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754740AbZKDIwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 03:52:44 -0500
In-Reply-To: <4AF011A6.1070903@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Nov 2009, YOSHIFUJI Hideaki wrote:
>>  RFC 2526: Reserved IPv6 Subnet Anycast Addresses
>>  RFC 3627: Use of /127 Prefix Length Between Routers Considered Harmful
>
> I should say "Subnet-router anycast address" and
> RFC3513: Internet Protocol Version 6 (IPv6) Addressing
> Architecture".

FWIW, please note that commercial vendors haven't implemented this 
very extensively, and there's also some recent activity arguing this 
is not very useful:

http://tools.ietf.org/html/draft-kohno-ipv6-prefixlen-p2p-00

We'll likely get better idea how folks react to this during the next 
week's IETF.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
