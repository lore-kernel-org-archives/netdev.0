From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 12:50:49 -0700
Message-ID: <20140506195049.GO19657@tassilo.jf.intel.com>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <20140506191447.GB4137@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, David Miller <davem@davemloft.net>,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11039 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974AbaEFTu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 15:50:57 -0400
Content-Disposition: inline
In-Reply-To: <20140506191447.GB4137@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> So I think Dave is right
> in rejecting anything that compromises the _quality_ of the stack.

I don't think anything I removed compromised quality (modulo bugs)
It's still a more-features-than-your-typical-BSD TCP/IP stack

-Andi
