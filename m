From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 4/11][IPV4] Use ctl paths to register
 net/ipv4/ table
Date: Wed, 05 Dec 2007 01:41:36 -0800 (PST)
Message-ID: <20071205.014136.196953979.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475526ED.7070802@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbXLEJlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:41:37 -0500
In-Reply-To: <475526ED.7070802@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:07:41 +0300

> This is the same as I did for the net/core/ table in the
> second patch in his series: use the paths and isolate the 
> whole table in the .c file.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
