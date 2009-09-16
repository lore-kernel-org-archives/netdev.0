From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: igb bandwidth allocation configuration
Date: Wed, 16 Sep 2009 09:47:28 +0300
Message-ID: <4AB08A00.40102@voltaire.com>
References: <20090910081844.GA5421@verge.net.au>	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>	<20090915113659.GJ24194@verge.net.au> <4AAF963D.4060708@voltaire.com>	<4AAFD690.5040900@intel.com> <20090915222926.GA24467@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:34663 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750879AbZIPGrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 02:47:31 -0400
In-Reply-To: <20090915222926.GA24467@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> My reading of the documentation is also that its a minimum percentage of bandwidth. But after playing with the registers a bit it seems that it is actually a ceiling expressed. And the percentage is of 1Gigabit, regardless of the actual link speed.
Hi,

Does the documentation you refer to is the 82576 one? if yes, can you 
send a pointer to the doc/section you refer to? also is there 82599 
(Niantic) documentation which is publicly avail and I can look at? 
specifically, I would love taking a look on the equivalent of the "Intel 
82576 SR-IOV Driver Companion Guide"


Or.

