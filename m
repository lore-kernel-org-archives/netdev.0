From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000: Removing the unused macro
	PAGE_USE_COUNT()
Date: Tue, 17 Feb 2009 15:27:01 -0800
Message-ID: <9929d2390902171527q62af2fdcnb99a9dd45e2b13bb@mail.gmail.com>
References: <499AD0D4.2000504@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:25308 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbZBQX1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 18:27:02 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1202014yxm.1
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 15:27:01 -0800 (PST)
In-Reply-To: <499AD0D4.2000504@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2009 at 6:59 AM, Breno Leitao <leitao@linux.vnet.ibm.com> wrote:
> Removing the unused macro PAGE_USE_COUNT(), since there is no more reference
> to it. The last reference was removed by Jesse's commit number
> 630b25cdf4e3f8c0a11eb04fc8436cc36653cd58.
>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> ---
>  drivers/net/e1000/e1000_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

-- 
Cheers,
Jeff
