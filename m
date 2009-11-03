From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 14427] New: ipv6 forward cause strange route
Date: Tue, 03 Nov 2009 20:19:02 +0900
Message-ID: <4AF011A6.1070903@linux-ipv6.org>
References: <bug-14427-10286@http.bugzilla.kernel.org/> <20091102223237.c0102f19.akpm@linux-foundation.org> <4AF00EA0.7030407@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Pekka Savola <pekkas@netcore.fi>,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>, green@msu.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56778 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751200AbZKCLTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 06:19:01 -0500
In-Reply-To: <4AF00EA0.7030407@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
> This is not a bug but a feature of IPv6 called "subnet anycast
> address."  The address is automatically assigned on routers.
> 
> References:
> RFC 2526: Reserved IPv6 Subnet Anycast Addresses
> RFC 3627: Use of /127 Prefix Length Between Routers Considered Harmful

I should say "Subnet-router anycast address" and
RFC3513: Internet Protocol Version 6 (IPv6) Addressing
Architecture".

Sorry for confusion.

--yoshfuji
