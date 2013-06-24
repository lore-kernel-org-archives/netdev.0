From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gre: fix a possible skb leak
Date: Mon, 24 Jun 2013 07:36:00 -0700
Message-ID: <1372084560.3301.68.camel@edumazet-glaptop>
References: <1372080360.3301.61.camel@edumazet-glaptop>
	 <20130624140359.GA28057@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:37402 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3FXOf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 10:35:59 -0400
Received: by mail-ea0-f170.google.com with SMTP id h10so6251842eaj.1
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 07:35:57 -0700 (PDT)
In-Reply-To: <20130624140359.GA28057@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 16:03 +0200, Veaceslav Falico wrote:

> Maybe we can also use it here (build-tested only):

Sure, but it will be done later on net-next

This patch is a stable candidate, so I made a somewhat minimal change
