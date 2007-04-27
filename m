From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 ethernet bonding problems
Date: Sat, 28 Apr 2007 00:58:41 +0200
Message-ID: <20070427225841.GA1066@electric-eye.fr.zoreil.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com> <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38799 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757764AbXD0XCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 19:02:10 -0400
Content-Disposition: inline
In-Reply-To: <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> A tcpdump trace 1) before promiscuous mode 2) after promiscuous mode 3)
> after link failure (i.e. failover does not work) would be welcome.

A 'lspci -vx' will be needed too. There are different kinds of 8169.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
