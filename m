From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] mlx4: needs vmalloc.h for vmap()
Date: Mon, 11 Feb 2008 14:34:20 -0800
Message-ID: <ada7ihbxgur.fsf@cisco.com>
References: <20080211221115.GH4516@phobos.i.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rolandd@cisco.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:22621 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644AbYBKWef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:34:35 -0500
In-Reply-To: <20080211221115.GH4516@phobos.i.cabal.ca> (Kyle McMartin's message of "Mon, 11 Feb 2008 17:11:15 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks, just merged the same patch from Olof Johansson.
