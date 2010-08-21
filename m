From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2: tc: f_flow: add key rxhash
Date: Sat, 21 Aug 2010 17:42:17 -0400
Message-ID: <1282426937.3532.6.camel@bigi>
References: <1282408201-3522-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:52353 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab0HUVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 17:42:20 -0400
Received: by qwh6 with SMTP id 6so4135461qwh.19
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 14:42:20 -0700 (PDT)
In-Reply-To: <1282408201-3522-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-08-22 at 00:30 +0800, Changli Gao wrote:
> We can use rxhash to classify the traffic into flows. As rxhash maybe
> supplied by NIC or RPS, it is cheaper.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

