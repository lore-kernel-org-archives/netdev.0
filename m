From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 16:30:01 -0700
Message-ID: <1414711801.499.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
	 <20141028.165737.2009356944765978630.davem@davemloft.net>
	 <20141029122307.GA29253@breakpoint.cc>
	 <20141030.155958.156984068627586090.davem@davemloft.net>
	 <20141030205204.GE10069@breakpoint.cc>
	 <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141030221501.GA9416@breakpoint.cc>
	 <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141030231637.GF10069@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52660 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161292AbaJ3XaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:30:04 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so210328ier.6
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 16:30:03 -0700 (PDT)
In-Reply-To: <20141030231637.GF10069@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-31 at 00:16 +0100, Florian Westphal wrote:

> I see. So that makes ecn=1 default a pure fantasy.

Well, I had this dream about 2 or 3 years ago, but I eventually came to
this (sad) conclusion.
