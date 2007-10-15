From: xeb@mail.ru
Subject: =?koi8-r?Q?Re[2]=3A_Kernel_panic_(network_stack)?=
Date: Mon, 15 Oct 2007 16:14:58 +0400
Message-ID: <E1IhOqY-000FCU-00.xeb-mail-ru@f25.mail.ru>
References: <20071012102045.3f181605@freepuppy.rosehill>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx28.mail.ru ([194.67.23.67]:1194 "EHLO mx28.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbXJOVTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:19:30 -0400
Received: from f25.mail.ru (f25.mail.ru [194.67.57.151])
	by mx28.mail.ru (mPOP.Fallback_MX) with ESMTP id E2A2EF84D8
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 16:15:40 +0400 (MSD)
In-Reply-To: <20071012102045.3f181605@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Hello!
> > I develop network driver.
> > It works fine while less then 100 network interfaces exists.
> > Then i give kernel panic. What could cause it ?
> > 
> 
> Since it probably in your code. Please code (or place to download)
> the driver code.

fixed in 0.7.9
