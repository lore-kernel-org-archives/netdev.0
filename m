From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] pppoe: use phonet_pernet instead of
 directly net_generic
Date: Mon, 26 Apr 2010 20:45:33 +0200
Message-ID: <20100426184532.GB2933@psychotron.redhat.com>
References: <20100426134100.GF2941@psychotron.lab.eng.brq.redhat.com>
 <20100426.111747.115930051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197Ab0DZSpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 14:45:39 -0400
Content-Disposition: inline
In-Reply-To: <20100426.111747.115930051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 26, 2010 at 08:17:47PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Mon, 26 Apr 2010 15:41:00 +0200
>
>> As in for example pppoe introduce phonet_pernet and use it instead of calling
>> net_generic directly.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Applied, and I modified your commit header line slightly.  This isn't
>a change to "pppoe: " but rather "phonet: " :-)

Ups, copy/paste mistake. Thanks.
>
>Thanks.
