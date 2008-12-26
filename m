From: David Miller <davem@davemloft.net>
Subject: Re: [patch 05/10] 802.3ad: initialize ports LACPDU from const
 initializer
Date: Fri, 26 Dec 2008 13:28:40 -0800 (PST)
Message-ID: <20081226.132840.252542154.davem@davemloft.net>
References: <20081223220101.747816175@jonathan.eitzenberger.org>
	<20081223220556.302688266@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752830AbYLZV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 16:28:37 -0500
In-Reply-To: <20081223220556.302688266@jonathan.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>
Date: Tue, 23 Dec 2008 23:01:06 +0100

> Save some text by initializing ports LACPDU from const initializer,
> then get rid of ad_initialize_lacpdu().
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
