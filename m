From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-04-20
Date: Tue, 20 Apr 2010 18:04:53 -0700 (PDT)
Message-ID: <20100420.180453.71193009.davem@davemloft.net>
References: <20100420183013.GC6472@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754353Ab0DUBEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:04:48 -0400
In-Reply-To: <20100420183013.GC6472@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 20 Apr 2010 14:30:14 -0400

> Here are a few more intended for 2.6.34, mostly from the iwlwifi team.
> They fix a couple of potential crashes, an incorrect EEPROM offset
> related to regulatory information, and a connectivity failure relating
> to 802.11n and the 4965.  The "iwlwifi: fix scan races" seems a little
> long, but much of it is the fallout from renaming a goto label.

Pulled, thanks John.
