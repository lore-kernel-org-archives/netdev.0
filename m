From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Sun, 5 May 2013 21:33:23 +0200
Message-ID: <20130505193323.GA21121@electric-eye.fr.zoreil.com>
References: <20130426205018.GA18092@electric-eye.fr.zoreil.com>
 <20130427041230.GA18709@gmail.com>
 <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
 <20130501223155.GA15261@electric-eye.fr.zoreil.com>
 <20130502021848.GA30099@gmail.com>
 <20130502221837.GA9898@electric-eye.fr.zoreil.com>
 <20130505151732.GA9096@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lance Lassetter <lancelassetter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37111 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab3EETd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 15:33:28 -0400
Content-Disposition: inline
In-Reply-To: <20130505151732.GA9096@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lance Lassetter <lancelassetter@gmail.com> :
[...]
> What do you think, Ueimor ?

I think you should try a post 3.9 kernel including commit
4ada8db38a44654446fe35ceb20a1972220e0f69 ("net: Restore NETIF_F_* bit
ordering.").

-- 
Ueimor
