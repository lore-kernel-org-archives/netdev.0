From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Fri, 18 Jul 2008 09:27:21 -0400
Message-ID: <1216387641.4833.96.camel@localhost>
References: <487F4327.1000107@trash.net>
	 <1216301732.4726.26.camel@localhost>	<487F50EC.80008@trash.net>
	 <20080717.152447.89672084.davem@davemloft.net>  <487FDA67.30902@trash.net>
	 <1216386624.4833.94.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:2446 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYGRN11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:27:27 -0400
Received: by wr-out-0506.google.com with SMTP id 69so215184wri.5
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 06:27:24 -0700 (PDT)
In-Reply-To: <1216386624.4833.94.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-07 at 09:10 -0400, jamal wrote:

> wire still even on multiple rings;->
> If Woz (really) showed up at 9am and the Broussards at 3 am[1] on that
> single (congestion-buffering) FIFO waiting for the shop/wire to open up,
> then Woz should jump the queue (if he deserves it) when shop opens at
> 10am.

Sorry, the url of Woz allegedly jumping the queue:
http://news.cnet.com/8301-1023_3-9989823-93.html?hhTest=1%C3%A2%C2%88%
C2%82=rss&subj=news&tag=2547-1_3-0-20

cheers,
jamal

