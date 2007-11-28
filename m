From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 18:01:20 -0800
Message-ID: <474CCBF0.5060809@hp.com>
References: <20071122343.446909000@suse.de> <adatznarrzc.fsf@cisco.com>	<200711261228.15155.rusty@rustcorp.com.au>	<20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>	<20071127190037.GB30057@redhat.com>	<20071127210942.GF3406@stusta.de> <474C88EB.9040300@hp.com> <20071127213837.GG3406@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:15267 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbXK1CCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 21:02:23 -0500
In-Reply-To: <20071127213837.GG3406@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Tue, Nov 27, 2007 at 01:15:23PM -0800, Rick Jones wrote:
> 
>>>The real problem is that these drivers are not in the upstream kernel.
>>>
>>>Are there common reasons why these drivers are not upstream?
>>
>>One might be that upstream has not accepted them.  Anything doing or 
>>smelling of TOE comes to mind right away.
> 
> 
> Which modules doing or smelling of TOE do work with unmodified vendor 
> kernels?

At the very real risk of further demonstrating my Linux vocabulary 
limitations, I believe there is a "Linux Sockets Acceleration" 
module/whatnot for NetXen and related 10G NICs, and a cxgb3_toe (?) 
module for Chelsio 10G NICs.

rick jones
