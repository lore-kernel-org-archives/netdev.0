From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-2.6.25][NETNS] make netns cleanup to run in a
 separate workqueue
Date: Mon, 19 Nov 2007 23:18:34 -0800 (PST)
Message-ID: <20071119.231834.115257346.davem@davemloft.net>
References: <47416909.4000602@fr.ibm.com>
	<47416DF3.700@sw.ru>
	<47416EC1.7080702@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, ebiederm@xmission.com,
	containers@lists.osdl.org, den@openvz.org, benjamin.thery@bull.net
To: dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52378
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753335AbXKTHSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:18:35 -0500
In-Reply-To: <47416EC1.7080702@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Korotaev <dev@sw.ru>
Date: Mon, 19 Nov 2007 14:08:49 +0300

> Acked-By: Kirill Korotaev <dev@sw.ru>

I've applied this patch, thanks everyone.
