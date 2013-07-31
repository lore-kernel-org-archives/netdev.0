From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: 3.10, iwlwifi 6200AGN: AP changed bandwidth in a way we can't
 support - disconnect
Date: Wed, 31 Jul 2013 07:57:37 -0700
Message-ID: <20130731145737.GC31017@hexapodia.org>
References: <20130729163452.GA454@hexapodia.org>
 <20130731085956.GC1681@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from straum.hexapodia.org ([66.109.99.53]:44419 "EHLO
	straum.hexapodia.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442Ab3GaO5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 10:57:38 -0400
Content-Disposition: inline
In-Reply-To: <20130731085956.GC1681@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 10:59:56AM +0200, Stanislaw Gruszka wrote:
> We have few reports about this. Johannes, proposed this patch
> http://p.sipsolutions.net/9d1dd0734d2c3a7a.txt
> 
> Could you check if it fixes the problem for you?

I unfortunately didn't get a chance to confirm before leaving Berlin,
but the patch Johannes posted in the other thread seems to agree with my
analysis of the problem, and Johannes confirmed from my pcap that it
is the same problem.

-andy
