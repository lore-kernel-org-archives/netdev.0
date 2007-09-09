From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] e100: timer power saving
Date: Sun, 09 Sep 2007 15:37:43 -0700
Message-ID: <46E475B7.2060203@linux.intel.com>
References: <20070906185137.30733.99594.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:40747 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752575AbXIIWsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 18:48:00 -0400
In-Reply-To: <20070906185137.30733.99594.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Since E100 timer is 2HZ, use rounding to make timer occur on the
> correct boundary.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

given that I was about to send out exactly this same patch...


Acked-by: Arjan van de Ven <arjan@linux.intel.com>
