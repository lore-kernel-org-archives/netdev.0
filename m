From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 2/3] eth: Make is_link_local() consistent with
 other address tests
Date: Thu, 01 Nov 2012 17:33:31 -0700
Message-ID: <509314DB.9060700@intel.com>
References: <1351797071.2883.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57133 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab2KBAdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 20:33:35 -0400
In-Reply-To: <1351797071.2883.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/1/2012 12:11 PM, Ben Hutchings wrote:
> Function name should include '_ether_addr'.
> Return type should be bool.
> Parameter name should be 'addr' not 'dest' (also matching kernel-doc).
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Thanks for cleaning this up Ben.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
