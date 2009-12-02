From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 9/9] e1000e: Use sizeof struct rather than
 pointer in e1000_get_eeprom()
Date: Wed, 02 Dec 2009 00:38:26 -0800 (PST)
Message-ID: <20091202.003826.120472359.davem@davemloft.net>
References: <20091202015250.592.56893.stgit@localhost.localdomain>
	<20091202015406.592.42534.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, roel.kluin@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754917AbZLBIiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:38:19 -0500
In-Reply-To: <20091202015406.592.42534.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:54:24 -0800

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> Don't use the sizeof the pointer to clear the result
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
