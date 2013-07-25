From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Wed, 24 Jul 2013 20:16:48 -0700
Message-ID: <1374722208.1924.36.camel@joe-AO722>
References: <b939bb41630693171771c108801c1c5f688ecabc.1374525261.git.dvhart@linux.intel.com>
	 <cover.1374525261.git.dvhart@linux.intel.com>
	 <79241b53ec4e638008ba3384958ef9901ad11338.1374525261.git.dvhart@linux.intel.com>
	 <20130724.170008.924195436945641752.davem@davemloft.net>
	 <1374711603.3436.246.camel@dvhart-mobl1.amr.corp.intel.com>
	 <1374712895.1924.13.camel@joe-AO722>
	 <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hpa@zytor.com, peter.p.waskiewicz.jr@intel.com,
	andriy.shevchenko@linux.intel.com
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55619 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753231Ab3GYDQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 23:16:50 -0400
In-Reply-To: <1374721094.3436.249.camel@dvhart-mobl1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 19:58 -0700, Darren Hart wrote:
> I was following the existing style of the file (with the exception of
> the leading two ** as checkpatch complains.

I just tested and duplicated that.

It's a checkpatch defect.
I'll fix it.  Ignore it for now.

cheers, Joe
