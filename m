From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] mac802154: make multiple WPAN handling
 sensible
Date: Mon, 31 Mar 2014 20:48:41 +0200
Message-ID: <20140331184838.GA990@omega.Speedport_W_921V_1_24_000>
References: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:49685 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbaCaSsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 14:48:47 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so6237273wgg.18
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 11:48:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phoebe,

I got a:

RTNETLINK answers: Unknown error 524

when I try to make a "ip link set wpan0 up" after iz add.

"iz listphy" shows the wpan device.

- Alex
