From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] timer: Export destroy_hrtimer_on_stack()
Date: Tue, 31 May 2016 11:44:18 -0700 (PDT)
Message-ID: <20160531.114418.1475211742163432251.davem@davemloft.net>
References: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbcEaSoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:44:19 -0400
In-Reply-To: <1464308466-16525-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Thu, 26 May 2016 17:21:05 -0700

> hrtimer_init_on_stack() needs a matching call to
> destroy_hrtimer_on_stack(), so both need to be exported.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
