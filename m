From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net_sched: cls_flow: add key rxhash
Date: Sat, 21 Aug 2010 17:41:32 -0400
Message-ID: <1282426892.3532.5.camel@bigi>
References: <1282407795-3449-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:64082 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab0HUVlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 17:41:37 -0400
Received: by qyk9 with SMTP id 9so1651571qyk.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 14:41:36 -0700 (PDT)
In-Reply-To: <1282407795-3449-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-08-22 at 00:23 +0800, Changli Gao wrote:
> We can use rxhash to classify the traffic into flows. As rxhash maybe
> supplied by NIC or RPS, it is cheaper.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Nice idea.
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

