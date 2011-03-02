From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC LOL OMG] pfifo_lat: qdisc that limits dequeueing based on
 estimated link latency
Date: Wed, 2 Mar 2011 17:08:29 -0500
Message-ID: <20110302220828.GA3097@tuxdriver.com>
References: <20110228132341.194975v6ojrudl18@hayate.sektori.org>
 <1299102850-2883-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bloat-devel@lists.bufferbloat.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53230 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1CBWJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:09:20 -0500
Content-Disposition: inline
In-Reply-To: <1299102850-2883-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 04:54:10PM -0500, John W. Linville wrote:
> This is a qdisc based on the existing pfifo_fast code.  The difference

Well, it started that way.  This is obviously based on the pfifo
code instead...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
