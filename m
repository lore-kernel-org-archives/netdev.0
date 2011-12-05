From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC PATCH 3/5] macvtap: flow director support
Date: Mon, 5 Dec 2011 20:11:10 +0000
Message-ID: <1323115870.2887.14.camel@bwh-desktop>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	 <20111205085906.6116.84426.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <krkumar2@in.ibm.com>, <kvm@vger.kernel.org>, <mst@redhat.com>,
	<netdev@vger.kernel.org>, <rusty@rustcorp.com.au>,
	<virtualization@lists.linux-foundation.org>,
	<levinsasha928@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39051 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756158Ab1LEULO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 15:11:14 -0500
In-Reply-To: <20111205085906.6116.84426.stgit@dhcp-8-146.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly, macvtap chould implement the ethtool {get,set}_rxfh_indir
operations.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
