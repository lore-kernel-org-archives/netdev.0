From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] ATM: Fix wrong usage of INIT_WORK
Date: Thu, 7 Jul 2011 08:29:59 -0400
Message-ID: <20110707082959.7a579a29@thirdoffive.cmf.nrl.navy.mil>
References: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
	<20110707.045159.735589070219101177.davem@davemloft.net>
	<CANxBZFo_2P+hrjNDmvU0wai2CA7Ry3LJ9vk+pZ4ML1RR12LKTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	wangshaoyan.pt@taobao.com, linux-atm-general@lists.sourceforge.net
To: Wang Shaoyan <stufever@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:52201 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916Ab1GGMkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 08:40:17 -0400
In-Reply-To: <CANxBZFo_2P+hrjNDmvU0wai2CA7Ry3LJ9vk+pZ4ML1RR12LKTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Jul 2011 20:04:25 +0800
Wang Shaoyan <stufever@gmail.com> wrote:

> I just don't know whether the marco FILL_RX_POOLS_IN_BH is useful?

the macro doesnt seem to be useful in anyway.  it can simply be
eliminated.
