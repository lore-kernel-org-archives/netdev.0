From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/2] act_mirred: cleanup
Date: Mon, 16 Nov 2009 04:24:39 -0500
Message-ID: <1258363479.3251.25.camel@bigi>
References: <412e6f7f0911160033h649b44b2o669196b8b14bf6fc@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:53049 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbZKPJYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 04:24:39 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1029913qwe.37
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 01:24:45 -0800 (PST)
In-Reply-To: <412e6f7f0911160033h649b44b2o669196b8b14bf6fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 16:33 +0800, Changli Gao wrote:
> act_mirred: cleanup
> 
> 1. don't let go back using goto.
> 2. don't call skb_act_clone() until it is necessary.
> 3. one exit of the critical context.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

