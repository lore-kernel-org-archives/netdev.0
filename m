From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [RFC] sk_nulls_next_rcu
Date: Mon, 30 Nov 2009 22:59:29 -0200
Message-ID: <20091201005929.GB21463@ghostprotocols.net>
References: <200912010219.29340.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:60936 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbZLAXSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 18:18:42 -0500
Received: by gxk26 with SMTP id 26so110942gxk.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 15:18:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200912010219.29340.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Dec 01, 2009 at 02:19:29AM +0200, Octavian Purdila escreveu:
> 
> I am trying to convert the LLC code to RCU, and it appears that for proc 
> support a sk_nulls_next_rcu would be required. 

I find it amusing, and give you a carte blanche on that! :-)

- Arnaldo
