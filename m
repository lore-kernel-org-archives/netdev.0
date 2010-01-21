From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] DMA sync errors
Date: Wed, 20 Jan 2010 16:36:37 -0800 (PST)
Message-ID: <20100120.163637.124075249.davem@davemloft.net>
References: <20100120152832.06a905a5@nehalam>
	<20100120.161805.118613816.davem@davemloft.net>
	<20100120163410.774f0c4c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47008
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752194Ab0AUAg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 19:36:26 -0500
In-Reply-To: <20100120163410.774f0c4c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 20 Jan 2010 16:34:10 -0800

> check_unmap has checks for different size, different type,
> call_ents, direction etc.
> 
> The code for get_nr_mapped_entries() is the only question;
> it is used by unmap_sg() and probably needs perfect match only.

Ok.
