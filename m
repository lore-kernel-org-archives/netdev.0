From: Brian Haley <brian.haley@hp.com>
Subject: Re: rx_dropped packets stop with tcpdump running
Date: Fri, 20 Apr 2012 10:59:47 -0400
Message-ID: <4F9179E3.5020507@hp.com>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>,<1334841865.2395.177.camel@edumazet-glaptop>,<1334842088.2395.178.camel@edumazet-glaptop>,<061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com> <DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tushar.n.dave@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:20450 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab2DTO7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 10:59:50 -0400
In-Reply-To: <DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2012 04:34 AM, Marco Berizzi wrote:
> 
> tushar.n.dave@intel.com wrote:
>> Marco,
> 
> Hi Dave,
> 
> as pointed by Eric, the counter is
> increasing because a windows box is
> sending out packets with ethertype
> 0x886d

0x886d or 0x86DD?  That second one is IPv6, you might just need to load the module.

-Brian
