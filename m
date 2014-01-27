From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: stmmac: Log MAC address only once
Date: Sun, 26 Jan 2014 22:43:06 -0800 (PST)
Message-ID: <20140126.224306.1861545181099799914.davem@davemloft.net>
References: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
	<1390747844-25060-2-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaA0GnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:43:07 -0500
In-Reply-To: <1390747844-25060-2-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Sun, 26 Jan 2014 15:50:44 +0100

> Logging the MAC address on every if-up, is not really useful, and annoying when
> there is no cable inserted and NetworkManager tries the ifup every 50 seconds.
> 
> Also change the log level from warning to info, as that is what it is.
> 
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Applied.
