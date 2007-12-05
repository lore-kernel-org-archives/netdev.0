From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 7/11] ibm_newemac: Skip EMACs that are marked unused by
	the firmware
Date: Wed, 05 Dec 2007 15:18:49 +1100
Message-ID: <1196828329.13230.356.camel@pasglop>
References: <20071205001539.97730DE091@ozlabs.org>
	 <20071205035345.GA12855@localhost.localdomain>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52602 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbXLEETm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 23:19:42 -0500
In-Reply-To: <20071205035345.GA12855@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2007-12-05 at 14:53 +1100, David Gibson wrote:
> It occurred to me the other day.  Instead of using a new "unused"
> property for this, should we be using the OF standard "status"
> property.

Dunno... it's really not wired. Probably not even clocked.

Ben.


