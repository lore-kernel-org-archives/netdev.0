From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/11][CORE] Isolate the net/core/ sysctl
 table
Date: Wed, 05 Dec 2007 01:37:42 -0800 (PST)
Message-ID: <20071205.013742.230707657.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<47552633.8040306@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751941AbXLEJhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:37:42 -0500
In-Reply-To: <47552633.8040306@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:04:35 +0300

> Using ctl paths we can put all the stuff, related to net/core/
> sysctl table, into one file and remove all the references on it.
> 
> As a good side effect this hides the "core_table" name from
> the global scope :)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
