From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH v2 -next] 6LoWPAN: fix skb_copy call
Date: Thu, 1 Sep 2011 15:10:08 +0300
Message-ID: <CAEnQRZAYXs6DJrci=mBNWuNLiCJk3AuyGiTCqQoQFQN02eQdJQ@mail.gmail.com>
References: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1314881653-1104-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:56694 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1IAMKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 08:10:09 -0400
In-Reply-To: <1314881653-1104-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBpZiAoTlVMTCA9PSBza2IpIHsKPiArIKAgoCCgIKAg
oCCgIKAgoCCgIKAgoCCgIKAgoCCgIHN0YXQgPSAtRU5PTUVNOwo+ICsgoCCgIKAgoCCgIKAgoCCg
IKAgoCCgIKAgoCCgIKAgYnJlYWs7Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgfQoKVGhpcyBj
YW4gaHVydCBvdXIgZXllcyA6KS4gSSB0aGluayB0aGUgY29tbW9uIGNvbnZlbnRpb24KaXMgdG8g
dXNlOiAiaWYgKHNrYiA9PSBOVUxMKSAiIG9yIHNpbXBseSAiaWYgKCFza2IpICIKCnRoYW5rcywK
RGFuaWVsLgo=
