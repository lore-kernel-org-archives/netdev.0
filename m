From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH] bnx2 - Don't use reserved names
Date: Wed, 8 Apr 2009 14:47:05 -0700
Message-ID: <20090408214705.GA12006@deprecation.cyrius.com>
References: <20090408211656.GA21010@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Bastian Blank <waldi@debian.org>, davem@davemloft.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:37149 "EHLO
	sorrow.cyrius.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756479AbZDHVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 17:47:11 -0400
Content-Disposition: inline
In-Reply-To: <20090408211656.GA21010@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Bastian Blank <waldi@debian.org> [2009-04-08 23:16]:
> The mips identifier is reserved by gcc on mips plattforms. Don't use it
> in the code.
> 
> Signed-off-by: Bastian Blank <waldi@debian.org>

This fixes the compile problem for me on MIPS.

Tested-by: Martin Michlmayr <tbm@cyrius.com>

-- 
Martin Michlmayr
http://www.cyrius.com/
