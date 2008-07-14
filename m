From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 2.6.26: iwl3945 failing to initialize wep, crypto modprobe failure?
Date: Mon, 14 Jul 2008 13:02:18 -0700
Message-ID: <487BB0CA.6090306@goop.org>
References: <487BB053.90804@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:53067 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756378AbYGNUCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 16:02:31 -0400
In-Reply-To: <487BB053.90804@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Fitzhardinge wrote:
> It's also possible I'm missing something from my .config (I'm in the 
> middle of trying to prune it).  It's below (compressed with "grep 
> ^CONFIG").

Duh.  Turned off KMOD.

Sorry for the noise,
    J
