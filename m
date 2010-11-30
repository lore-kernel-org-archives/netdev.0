From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: tc: f_flow: add key rxhash
Date: Tue, 30 Nov 2010 09:58:28 -0800
Message-ID: <20101130095828.392ff3f9@nehalam>
References: <1282408201-3522-1-git-send-email-xiaosuo@gmail.com>
	<1282426937.3532.6.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42525 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752233Ab0K3R6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 12:58:33 -0500
In-Reply-To: <1282426937.3532.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Aug 2010 17:42:17 -0400
jamal <hadi@cyberus.ca> wrote:

> On Sun, 2010-08-22 at 00:30 +0800, Changli Gao wrote:
> > We can use rxhash to classify the traffic into flows. As rxhash maybe
> > supplied by NIC or RPS, it is cheaper.
> > 
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> 
> cheers,
> jamal
> 

Applied

-- 
