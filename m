From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [net-next 2/8] maintainers: update with official intel support
 link, new maintainer
Date: Wed, 24 Oct 2012 10:31:05 -0700
Message-ID: <508825D9.6020306@hp.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com> <1350987887-16161-3-git-send-email-jeffrey.t.kirsher@intel.com> <1350998701.7502.42.camel@joe-AO722> <1351053166.2252.39.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Tushar Dave <tushar.n.dave@intel.com>, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:19697 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932947Ab2JXRbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 13:31:08 -0400
In-Reply-To: <1351053166.2252.39.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 09:32 PM, Jeff Kirsher wrote:
> So how do we go about giving this spider web of complex coverage to some
> clear concise coverage in the MAINTAINERS?

I happen to like seeing "real" names.  Is it possible to leverage email 
conventions to allow a comment of sorts with each email:

INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf)
M:      Jeff Kirsher (den mother) <jeffrey.t.kirsher@intel.com>
M:      Jesse Brandeburg (performance focus) <jesse.brandeburg@intel.com>
M:      Bruce Allan (e1000e focus) <bruce.w.allan@intel.com>
M:      Carolyn Wyborny (igb focus) <carolyn.wyborny@intel.com>
M:      Don Skidmore (omnibus) <donald.c.skidmore@intel.com>
M:      Greg Rose (omnibus) <gregory.v.rose@intel.com>
M:      Peter P Waskiewicz Jr (omnibus) <peter.p.waskiewicz.jr@intel.com>
M:      Alex Duyck (omnibus) <alexander.h.duyck@intel.com>
M:      John Ronciak (omnibus) <john.ronciak@intel.com>
M:      Tushar Dave (omnibus and rca) <tushar.n.dave@intel.com>

perhaps "any" or "all" rather than omnibus if that is too much a 
fifty-cent word.  Everyone is still in one place, but with some 
indication of specialization/generalization.  If the parenthesis form 
cannot be used, (I've not seen it elsewhere in MAINTAINERS) then perhaps 
the quoted form.

rick jones

(And yes, "den mother" was meant as a bit of levity :)
