From: David Dillow <dave@thedillows.org>
Subject: Re: network card with inline crypto engine?
Date: Tue, 19 Aug 2008 15:26:21 -0400
Message-ID: <1219173981.15135.22.camel@lap75545.ornl.gov>
References: <804fd2027cd558087a3db013b9ec80af@91.121.53.53>
	 <335b1a8e57d24608fae99045a49cb70b@91.121.53.53>
	 <1219168299.15135.15.camel@lap75545.ornl.gov>
	 <200808192110.08500.jcd@tribudubois.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jean-Christophe Dubois <jcd@tribudubois.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lap75545.ornl.gov ([160.91.210.54]:50949 "EHLO
	lap75545.ornl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbYHST00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 15:26:26 -0400
In-Reply-To: <200808192110.08500.jcd@tribudubois.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-08-19 at 21:10 +0200, Jean-Christophe Dubois wrote:
> Thanks David,
> 
> Out of curiosity, did you maintain you patch since 2.6.10/2.6.12? It seems you 
> were integrating comments but I don't think there has been a second 
> submission from you. It would be too bad to let it get lost.

We have the list archives for that! :)

I never finished updating it, and I've archived the WIP somewhere I'm
sure. So much has changed since then that it would likely be better to
start from scratch using the comments Dave made then.

Do you have a new device to use? I'd probably have finished it some time
ago, but the Typhoon is 100 MBps w/ 3DES, which doesn't seem
particularly useful these days with Gigabit AES links out there. I'm
also not sure if they still make the cards, though you can usually find
them on eBay. Intel makes a Pro100/S that does 3DES if I recall, but
it's the same issues, and they didn't seem interested in giving out docs
to it.
