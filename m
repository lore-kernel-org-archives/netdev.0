From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Tue, 30 Oct 2007 14:11:05 -0700 (PDT)
Message-ID: <20071030.141105.124578467.davem@davemloft.net>
References: <20071026153416.GA23491@bingen.suse.de>
	<20071030.005758.184980120.davem@davemloft.net>
	<200710301418.27643.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752446AbXJ3VLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 17:11:22 -0400
In-Reply-To: <200710301418.27643.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jean Delvare <jdelvare@suse.de>
Date: Tue, 30 Oct 2007 14:18:27 +0100

> OK, let's go with (512 * 1024) then. Want me to send an updated patch?

Why submit a patch that's already in Linus's tree :-)
