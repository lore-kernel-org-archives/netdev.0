From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation
 with IPv6 Neighbor Discovery
Date: Sat, 31 Aug 2013 02:20:56 -0300
Message-ID: <52217D38.3040804@gont.com.ar>
References: <20130813221321.AEA1AB1E003@rfc-editor.org> <520B3D81.9070506@gont.com.ar> <20130814230617.GA13066@order.stressinduktion.org> <520C7519.1010000@gont.com.ar> <20130815100407.GA18564@order.stressinduktion.org> <CAOp4FwSatwRtx_O4Aio4e0HmahxdwiY9JToc8E+1rMT9oCjLrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Loganaden Velvindron <loganaden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:36643 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476Ab3HaGpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 02:45:10 -0400
In-Reply-To: <CAOp4FwSatwRtx_O4Aio4e0HmahxdwiY9JToc8E+1rMT9oCjLrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 07:12 AM, Loganaden Velvindron wrote:
> 
> 
> I'm not sure if you got my previous mails, but I'd like to know a couple
> of things:
> 
> 1) How can I test this diff ?

Use the -y (fragmentation) option with the ns6, na6, r6, ra6, and rd6
tools of the IPv6 toolkit (http://www.si6networks.com/tools/ipv6toolkit)
-- there are are examples in the manpages.

Cheers,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
