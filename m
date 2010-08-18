From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 21:18:18 +0800
Message-ID: <AANLkTin9Pm0oPpteYsZsPUEyAj9qMxrSL9k1GXNYeY9h@mail.gmail.com>
References: <1282107908-3585-1-git-send-email-xiaosuo@gmail.com>
 <1282129364.23601.17.camel@bigi> <AANLkTi=50qHT_-OoMbWcPT1Fi7JEa0e_kReZhnpVJJdR@mail.gmail.com>
 <1282136070.23601.26.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64619 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015Ab0HRNSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:18:39 -0400
Received: by wyb32 with SMTP id 32so774458wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:18:38 -0700 (PDT)
In-Reply-To: <1282136070.23601.26.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 8:54 PM, jamal <hadi@cyberus.ca> wrote:
>
> Sounds sensible - but please go through the code and double check that
> nothing breaks (since i dont think you tested and i sympathize it would
> be very time consuming to test) and more importantly when you make such
> fundamental changes at least make comments to that effect in the logs.
>

I had gone through the code before submitting this code. But it isn't
easy to test if it breaks sth. Would you please give a case to test ?
Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
