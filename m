From: David Miller <davem@davemloft.net>
Subject: Re: [net 5/6] drivers/net/*: Fix FSF address in file headers
Date: Fri, 06 Dec 2013 12:38:39 -0500 (EST)
Message-ID: <20131206.123839.1803336848672529057.davem@davemloft.net>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	haiyangz@microsoft.com, kys@microsoft.com, paulus@samba.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	rusty@rustcorp.com.au, mst@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758233Ab3LFRim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:38:42 -0500
In-Reply-To: <1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  6 Dec 2013 06:28:47 -0800

> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
