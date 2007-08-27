From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6.24 patch] the planned eepro100 removal
Date: Mon, 27 Aug 2007 14:58:05 -0700
Message-ID: <46D348ED.9020003@intel.com>
References: <20070827212825.GY4121@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19963 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965494AbXH0V62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 17:58:28 -0400
In-Reply-To: <20070827212825.GY4121@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the planned removal of the eepro100 driver.
> 
> Signed-off-by: Adrian Bunk 

you lost your e-mail address? :)

> ---
> 
> This patch has been sent on:
> - 14 Aug 2007
> - 29 Jul 2007

currently we won't have e100 fixed up for ARM in 2.6.23, so removing this for 
2.6.24 sounds a bit premature. Maybe 2.6.25. Can you reschedule/postpone this?

Auke
