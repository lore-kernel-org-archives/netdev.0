From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] scsi_tcp: block BH in TCP callbacks
Date: Wed, 18 May 2016 14:48:02 -0700
Message-ID: <1463608082.18194.143.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
	 <1463532249-20850-2-git-send-email-edumazet@google.com>
	 <573CD513.3090501@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Venkatesh Srinivas <venkateshs@google.com>
To: Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36672 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbcERVsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 17:48:04 -0400
Received: by mail-pf0-f182.google.com with SMTP id c189so23149470pfb.3
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 14:48:03 -0700 (PDT)
In-Reply-To: <573CD513.3090501@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 15:48 -0500, Mike Christie wrote:

> Reviewed and tested. Thanks
> 
> Acked-by: Mike Christie <michaelc@cs.wisc.edu>

Excellent, thanks Mike !
