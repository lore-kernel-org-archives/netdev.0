From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_flow: add sanity check for the packet length
Date: Wed, 04 Aug 2010 10:18:25 -0400
Message-ID: <1280931505.5669.14.camel@bigi>
References: <1280905687-8463-1-git-send-email-xiaosuo@gmail.com>
	 <1280929183.5669.7.camel@bigi>
	 <AANLkTi=th9x0yWv3h1eT4Za7pqh0UDcT1QC_D9X1POOQ@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51025 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440Ab0HDQAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:00:47 -0400
Received: by fxm14 with SMTP id 14so2447047fxm.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 09:00:46 -0700 (PDT)
In-Reply-To: <AANLkTi=th9x0yWv3h1eT4Za7pqh0UDcT1QC_D9X1POOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-04 at 21:51 +0800, Changli Gao wrote:

> 
> Patrick thinks such things don't worth individual patches. I remember
> my such patch was applied by David. It is for netdev, not netfilter. I
> should obey David's rules. I'll remove this in the next version.

Probably Patrick was concerned about such a standalone patch with no
followup user; you need to have a followup user.

cheers,
jamal

