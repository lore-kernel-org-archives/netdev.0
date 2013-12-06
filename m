From: David Miller <davem@davemloft.net>
Subject: Re: [net 6/6] net/*: Fix FSF address in file headers
Date: Fri, 06 Dec 2013 12:39:28 -0500 (EST)
Message-ID: <20131206.123928.496536851032245462.davem@davemloft.net>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386350024-25308-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com,
	marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	jhs@mojatatu.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758287Ab3LFRja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:39:30 -0500
In-Reply-To: <1386350024-25308-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  6 Dec 2013 09:13:44 -0800

> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
