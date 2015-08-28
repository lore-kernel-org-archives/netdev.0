From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel
 state
Date: Fri, 28 Aug 2015 10:36:25 +0200
Message-ID: <20150828103625.51502177@griffin>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
	<20150823.165103.2104601245219561984.davem@davemloft.net>
	<20150826181926.0444240f@griffin>
	<20150826221330.GB31292@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbbH1Ig3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 04:36:29 -0400
In-Reply-To: <20150826221330.GB31292@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Aug 2015 00:13:30 +0200, Thomas Graf wrote:
> Did you test with a card that features UDP encapsulation offloads?

No, I did not. I do have access to NICs supporting it but I think in
this case, the numbers without vxlan offloading were more interesting.

 Jiri

-- 
Jiri Benc
