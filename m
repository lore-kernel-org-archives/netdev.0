From: Alexander Aring <alex.aring@gmail.com>
Subject: ieee802154: pull requests for ieee802154/mac802154 branches
Date: Tue, 29 Jul 2014 10:28:31 +0200
Message-ID: <20140729082829.GA2560@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: marcel@holtmann.org, davem@davemloft.net, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63341 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaG2I2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 04:28:38 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so535515wib.11
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 01:28:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to send pull-requests for the net/ieee802154 net/mac802154
implementation.

I know that bluetooth sends pull requests to linux-wireless to avoid
merge conflicts. My question is: Which branch is the best to send pull
requests for my case. Also I like to get the permission to do that.

I can send pull requests to linux-wireless or linux-net or
linux-bluetooth.

For the linux-bluetooth option:

There exists a new branch net/6lowpan which contains shared code between
bluetooth 6LoWPAN and IEEE 802.15.4 6LoWPAN implementation. Currently
Marcel apply patches for this branch and maybe it's better that I send
pull requests to the bluetooth branch, to avoid merge conflicts with the
net/6lowpan/* implementation.

Then I would base my pull request on the bluetooth-* branches.



Or should I send the pull requests to linux-wireless? I don't know the
right option, but I think I should send pull requests to linux-wireless
and take care about "possible" merge conflicts with bluetooth.


Thanks.

- Alex
