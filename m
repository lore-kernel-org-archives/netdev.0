From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Possible bug in realtek 8169 ethernet driver
Date: Mon, 6 Aug 2007 23:06:37 +0200
Message-ID: <20070806210637.GA18611@electric-eye.fr.zoreil.com>
References: <20070805155915.GM2761@avontuur.org> <20070805213557.GA21500@electric-eye.fr.zoreil.com> <20070806133752.GN2761@avontuur.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bram <bram@linux.kernel.as.avontuur.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46044 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760498AbXHFVHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 17:07:14 -0400
Content-Disposition: inline
In-Reply-To: <20070806133752.GN2761@avontuur.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bram <bram@linux.kernel.as.avontuur.org> :
[...]
> The device now works! But, it still comes up as eth2 instead of eth0,
> even though it's first detected as eth0. There are no other network

Check the udev rules and/or your init scripts ?

-- 
Ueimor
