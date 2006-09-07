From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Thu, 07 Sep 2006 15:28:18 -0700
Message-ID: <45009D02.10700@zytor.com>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060824105037.GL3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:41093 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S932251AbWIGW2m
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 18:28:42 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060824105037.GL3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> What about adding blackhole device to be used for such routes.
> I believe it would be good architecture to always use devices
> to state directions packets are being received from and sent to.

The dummy device can be used for that.

	-hpa

