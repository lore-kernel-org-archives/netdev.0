From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: remove delay at device dismantle
Date: Thu, 23 Aug 2012 04:58:37 +0200
Message-ID: <1345690717.5904.18.camel@edumazet-glaptop>
References: <1344613369.31104.2734.camel@edumazet-glaptop>
	 <1344664487.5158.1.camel@edumazet-glaptop>
	 <5035947C.8090609@cn.fujitsu.com>
	 <20120822.195111.765545116604962053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org,
	therbert@google.com, maheshb@google.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:58643 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab2HWC6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:58:45 -0400
Received: by wibhr14 with SMTP id hr14so333312wib.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 19:58:44 -0700 (PDT)
In-Reply-To: <20120822.195111.765545116604962053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 19:51 -0700, David Miller wrote:
> From: Gao feng <gaofeng@cn.fujitsu.com>

> > Hi Eric
> > 
> > I got this warning message with your patch applied.
> 
> Ok I won't push this out until this is resolved.

Thanks, I'll send a v2
