From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 v3 net-next] tg3: Add hwmon support
Date: Mon, 16 Jul 2012 23:11:28 -0700 (PDT)
Message-ID: <20120716.231128.1113699431084132190.davem@davemloft.net>
References: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46573 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057Ab2GQGL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 02:11:29 -0400
In-Reply-To: <1342491842-29818-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 16 Jul 2012 19:23:58 -0700

> David, I've removed the binary sysfs attribute and now use
> hwmon only.  Please consider this patchset for net-next.

Applied, thanks Michael.

You might want to add some Kconfig logic so that it's easier
to get the hwmon stuff automatically when tg3 is selected.
