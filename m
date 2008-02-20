From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [git patches] net driver fixes
Date: Wed, 20 Feb 2008 23:40:53 +0100
Message-ID: <20080220224053.GA8500@electric-eye.fr.zoreil.com>
References: <20080220165557.GA18816@havoc.gtf.org> <20080220.131530.18314167.davem@davemloft.net> <20080220212302.GJ30160@fieldses.org> <20080220.134257.41491836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41220 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933399AbYBTW7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:59:18 -0500
Content-Disposition: inline
In-Reply-To: <20080220.134257.41491836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Because it forces me to pull Linus's upstream into net-2.6,
> I don't have any choice in the matter.

Jeff's choice is a bit surprizing. That being said, it would had been nice
to fast-forward net-2.6 from a442585952f137bd4cdb1f2f3166e4157d383b82
to Linus's upstream before applying the content of
12aa343add3eced38a44bdb612b35fdf634d918c in order to keep the drift
with Linus's branch to a minimum during the bugfix cycle.

-- 
Ueimor
