From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Tue, 27 Nov 2012 13:07:08 -0300
Message-ID: <50B4E52C.8090507@gont.com.ar>
References: <50B4D43A.7030208@gont.com.ar> <1354032252.14302.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:46944 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab2K0QHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 11:07:25 -0500
In-Reply-To: <1354032252.14302.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric,

On 11/27/2012 01:04 PM, Eric Dumazet wrote:
>> P.S.: Not sure if this is the right list to send this note. Please
>> advice of a more appropriate one and/or feel free to forward this note
>> if deemed appropriate...
> 
> This seems a user space issue to me.
> 
> accept_ra on linux is set to 1, meaning that as soon as forwarding is
> enabled, RA are ignored.

I don't follow. Why would RAs be ignored if accept_ra is set to 1??

Cheers,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
