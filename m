From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] bfin_mac: Restore hardware time-stamping dependency on
 BF518
Date: Thu, 10 Jan 2013 17:40:16 +0100
Message-ID: <20130110164016.GA2295@netboy.at.omicron.at>
References: <1357828948-22682-1-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org
To: Lars-Peter Clausen <lars@metafoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:53326 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab3AJQkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:40:22 -0500
Received: by mail-wg0-f51.google.com with SMTP id gg4so368209wgb.30
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:40:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357828948-22682-1-git-send-email-lars@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2013 at 03:42:28PM +0100, Lars-Peter Clausen wrote:
> 
> This patch adds back the dependency on BF518, and since it does not make sense
> to expose this config option when the blackfin MAC driver is not enabled also
> restore the dependency on BFIN_MAC.

Thanks a lot for fixing this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
