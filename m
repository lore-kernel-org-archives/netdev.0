From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: ieee802154: pull requests for ieee802154/mac802154 branches
Date: Sun, 3 Aug 2014 21:29:26 +0200
Message-ID: <20140803192925.GA5664@omega>
References: <20140729082829.GA2560@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: marcel@holtmann.org, davem@davemloft.net, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:60895 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaHCT3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 15:29:33 -0400
Received: by mail-wi0-f174.google.com with SMTP id d1so3942165wiv.1
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2014 12:29:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140729082829.GA2560@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

ping?

I talked with Marcel today and he would accept pull request for
net/ieee802154 and net/mac802154 work. I will catch all patches from the
newly generated linux-wpan (IEEE 802.15.4/IEEE 802.15.4 6LoWPAN) list.

I would base my repository on bluetooth/bluetooth-next branches then.

This option is better, because there exist shared 6LoWPAN code which is
used by bluetooth and 802154.


David and John, is this okay for you? The alternative would be that I
send pull request to wireless, but then we have the net/6lowpan
conflicts issue. Bluetooth and 802154 should have the net/6lowpan
directory mostly up-to-date.

If this is fine, can I take all patches for net/mac802154 and net/ieee802154?
So no patches for this going into net-next/net to avoid conflicts.


For the net/6lowpan branch all patches should go into
bluetooth/bluetooth-next. Please let me know if this is fine.

Thanks.

- Alex
