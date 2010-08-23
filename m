From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Tue, 24 Aug 2010 00:26:31 +0200
Message-ID: <20100823222631.GA3612@nuttenaction>
References: <AANLkTimWaULcbxkUh5aCsM+6fWPaTM8CkZZh2hB_cQ3-@mail.gmail.com>
 <20100823220129.GB2745@nuttenaction>
 <AANLkTinb_tjcz=AF1-2i7MK=Bgm7aEtozjb3Ds0swi8q@mail.gmail.com>
 <20100823.152330.184822588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chris.snook@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi, acme@redhat.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:43754 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751585Ab0HWW0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:26:44 -0400
Content-Disposition: inline
In-Reply-To: <20100823.152330.184822588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-08-23 15:23:30 [-0700]:

>I completely agree with Chris that this should be a per-route rather
>than a global sysctl tunable.

OK, then I will follow Chris and re-spin the patch!

HGN
