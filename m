From: David Miller <davem@davemloft.net>
Subject: Re: net [BUG-FIX][PATCH 1/1] udplite: fast-path computation of
 checksum coverage
Date: Mon, 17 Oct 2011 19:07:44 -0400 (EDT)
Message-ID: <20111017.190744.56109078989285693.davem@davemloft.net>
References: <20111017213447.GA4061@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756208Ab1JQXIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:08:50 -0400
In-Reply-To: <20111017213447.GA4061@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Oct 2011 15:34:47 -0600

> can you please consider the fix below -- the checksum coverage in
> UDP-Lite had been broken for over half a year; then reported by
> Thomas. I have tested the patch below in various scenarios with IPv4
> and IPv6, on localhost, and between multiple hosts.

Applied, thanks a lot Gerrit.
