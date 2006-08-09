From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: d80211 merge plans
Date: Wed, 9 Aug 2006 10:19:10 +0200
Message-ID: <a32f33a40608090119p5f7efcaag506a41fa5fba9c8d@mail.gmail.com>
References: <200608090703.45651.mb@bu3sch.de>
	 <20060808.224838.41637123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, jbenc@suse.cz, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:23453 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S964927AbWHIIT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 04:19:26 -0400
Received: by py-out-1112.google.com with SMTP id z74so253854pyg
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2006 01:19:25 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060808.224838.41637123.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I am wondering about d80211 mainline merge plans.
>
> I think this is a non-started until the SMP problems are worked
> out.  Is it still SMP challenged?

Not sure what the SMP problems actually were,
but in the test results of rt2x00 I haven't come across
a SMP related problem yet. It could be that other non-SMP problems
are still hiding the SMP related problems, but I have not
yet found real SMP problems yet.
