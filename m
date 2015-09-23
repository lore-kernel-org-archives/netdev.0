From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: factorize sk_txhash init
Date: Tue, 22 Sep 2015 20:42:35 -0700
Message-ID: <1442979755.29850.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442878107.29850.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150922.173101.2074818900453085610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36325 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbbIWDmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 23:42:38 -0400
Received: by pacbt3 with SMTP id bt3so9429319pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 20:42:37 -0700 (PDT)
In-Reply-To: <20150922.173101.2074818900453085610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-22 at 17:31 -0700, David Miller wrote:

> This doesn't apply to net-next, please respin.

Sure.
