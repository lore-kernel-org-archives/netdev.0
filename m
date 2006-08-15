From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/10]: Improve SA insert/delete performance
Date: Tue, 15 Aug 2006 17:40:36 -0400
Message-ID: <1155678036.5122.4.camel@jzny2>
References: <20060815.043718.59464707.davem@davemloft.net>
	 <1155644137.6946.102.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:44464 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750728AbWHOVkm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 17:40:42 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GD6eT-0001qe-23
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 17:40:45 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <1155644137.6946.102.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 08:15 -0400, jamal wrote:

> Very cool ;-> Will test today.
> 

I can see in the range of ~50K SA adds per second ;->
I only went to about 350K SAs. A dual Xeon 2.6Ghz (sadly only with 1G
RAM).
So a small improvement from just the 5 initial patches; but nevertheless
a huge improvement from the current status quo. 
Good stuff!

cheers,
jamal

