From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.22-rc7] 8139cp: dev->tx_timeout
Date: Fri, 13 Jul 2007 23:04:47 +0200
Message-ID: <20070713210447.GA18669@electric-eye.fr.zoreil.com>
References: <4693B6ED.5030102@garzik.org> <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Mika.Lansirinne@stonesoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55225 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbXGMVFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 17:05:23 -0400
Content-Disposition: inline
In-Reply-To: <OF89ECFC4B.E1AA259B-ONC2257315.002C3B4B-C2257317.0054CDE1@stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika.Lansirinne@stonesoft.com <Mika.Lansirinne@stonesoft.com> :
[...]
> Can you test this one, this time it's made against the netdev-2.6 version.
> There indeed is a slight offset in the line numbers.

It still fails.

Fixed version follow.

-- 
Ueimor
