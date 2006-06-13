From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 01:19:27 +0900 (JST)
Message-ID: <20060614.011927.92331951.yoshfuji@linux-ipv6.org>
References: <1150213447.4200.37.camel@hookipa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:23556 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932166AbWFMQSk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 12:18:40 -0400
To: kazunori@miyazawa.org
In-Reply-To: <1150213447.4200.37.camel@hookipa>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1150213447.4200.37.camel@hookipa> (at Wed, 14 Jun 2006 00:44:06 +0900), Kazunori MIYAZAWA <kazunori@miyazawa.org> says:

> This patch introduces AES-XCBC-MAC using the "keyed hash" interface.
> It accordingly depends on the previous patch.
> 
> Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
