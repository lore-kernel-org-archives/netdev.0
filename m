From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Thu, 04 Apr 2013 09:18:58 -0700
Message-ID: <1365092338.3308.8.camel@edumazet-glaptop>
References: <1364917500.5113.176.camel@edumazet-glaptop>
	 <20130402155822.GB29115@redhat.com>
	 <20130402.121223.496337697838525487.davem@davemloft.net>
	 <1364920077.5113.185.camel@edumazet-glaptop>
	 <20130404153530.GA1688@minipsycho.brq.redhat.com>
	 <1365090287.3308.3.camel@edumazet-glaptop>
	 <20130404160706.GB1688@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61038 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762531Ab3DDQTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:19:00 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so1576396pad.16
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 09:19:00 -0700 (PDT)
In-Reply-To: <20130404160706.GB1688@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 18:07 +0200, Jiri Pirko wrote:

> I always thought that synchronize_rcu() is from the magic land of elfs and fairies...


;)
