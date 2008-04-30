From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII
	configurations
Date: Wed, 30 Apr 2008 09:36:01 +0200
Message-ID: <1209540962.18445.8.camel@gentoo-jocke.transmode.se>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org, wd@denx.de, domen.puncer@telargo.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:55740 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754256AbYD3HgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 03:36:06 -0400
In-Reply-To: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-04-29 at 17:06 -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> Various improvements for configuring the MPC5200 MII link from the
> device tree:
> * Look for 'current-speed' property for fixed speed MII links

Not that I have looked, but why can't you use the fixed-link property?

   Jocke
