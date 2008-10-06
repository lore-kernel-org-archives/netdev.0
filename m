From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/2] net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Mon, 06 Oct 2008 15:33:37 -0700
Message-ID: <ada3aj9pd4u.fsf@cisco.com>
References: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com>
	<20081006220920.3308.18862.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devel@open-fcoe.org
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:2649 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbYJFWdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:33:39 -0400
In-Reply-To: <20081006220920.3308.18862.stgit@zyfc9ini.jf.intel.com> (Yi Zou's
	message of "Mon, 06 Oct 2008 15:09:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 >  #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
 >  #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 > +#define ETH_P_FCOE      0x8906          /* Fibre Channel over Ethernet  */

trivial -- but the patch format makes it pretty obvious -- it would
probably be nice to use tabs to align things on the FCOE line the same
way the other lines in the file do, rather than using spaces.
