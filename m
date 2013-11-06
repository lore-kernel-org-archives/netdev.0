From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v3 1/2] net: Add layer 2 hardware acceleration
 operations for macvlan devices
Date: Wed, 06 Nov 2013 10:17:06 -0800
Message-ID: <527A87A2.1020800@intel.com>
References: <20131105232443.5400.97238.stgit@jf-dev1-dcblab> <20131105233011.5400.23253.stgit@jf-dev1-dcblab> <20131106.030157.1483150214352909742.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, alexander.h.duyck@intel.com,
	andy@greyhouse.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33464 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140Ab3KFSRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 13:17:22 -0500
In-Reply-To: <20131106.030157.1483150214352909742.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/2013 12:01 AM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Tue, 05 Nov 2013 15:30:12 -0800
>
>> +		 /* If we get a NULL pointer back, or if we get an error
>> +		  * then we should just fall through to the non accelerated path
>> +		  */
>
> Strange indentation here, two TABs and one SPACE instead of just two
> TABs.  Please fix, thanks.

Thanks, fixed in v4.
