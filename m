From: David Miller <davem@davemloft.net>
Subject: Re: Please pull 'p54' branch of wireless-2.6
Date: Wed, 19 Sep 2007 13:20:15 -0700 (PDT)
Message-ID: <20070919.132015.112854231.davem@davemloft.net>
References: <20070919195527.GD5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, flamingice@sourmilk.net
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750786AbXISUUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 16:20:15 -0400
In-Reply-To: <20070919195527.GD5483@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 19 Sep 2007 15:55:27 -0400

> This patch adds the p54 driver for prism54 hardware using the "soft
> MAC" firmware.  It includes modules for both PCI and USB drivers.
> 
> This driver has been in Fedora (both F7 and rawhide) for some time
> and has generally performed well.  No doubt there are some problems
> with the code, but still I think it would be better to mainline the
> driver than to keep it out of stream.

Merged to net-2.6.24, thanks John.
