From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: hard freezes on TX
Date: Fri, 8 Jun 2007 00:23:51 +0200
Message-ID: <20070607222351.GA32323@electric-eye.fr.zoreil.com>
References: <200705201520.36672.eike-kernel@sf-tec.de> <20070604214603.GA29311@electric-eye.fr.zoreil.com> <200706050933.28046.eike-kernel@sf-tec.de> <200706071613.47077.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50857 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764544AbXFGWY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 18:24:29 -0400
Content-Disposition: inline
In-Reply-To: <200706071613.47077.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rolf Eike Beer <eike-kernel@sf-tec.de> :
[...]
> fine. Even the next try with this file didn't produce a crash. What was 
> different on this tests was that I used the console instead of X (don't want 
> to munch up too many file systems). Any ideas?

X and friends ?

Can you send the usual dmesg, lspci -vvx and lsmod ?

-- 
Ueimor
