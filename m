From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 13:15:23 -0800
Message-ID: <474C88EB.9040300@hp.com>
References: <20071122343.446909000@suse.de> <adatznarrzc.fsf@cisco.com>	<200711261228.15155.rusty@rustcorp.com.au>	<20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>	<20071127190037.GB30057@redhat.com> <20071127210942.GF3406@stusta.de>
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
Received: from g4t0015.houston.hp.com ([15.201.24.18]:40340 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332AbXK0VP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 16:15:26 -0500
In-Reply-To: <20071127210942.GF3406@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The real problem is that these drivers are not in the upstream kernel.
> 
> Are there common reasons why these drivers are not upstream?

One might be that upstream has not accepted them.  Anything doing or 
smelling of TOE comes to mind right away.

rick jones
