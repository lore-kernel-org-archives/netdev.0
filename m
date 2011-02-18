From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 0/3] route cache deletion and cleanups
Date: Thu, 17 Feb 2011 16:34:11 -0800 (PST)
Message-ID: <20110217.163411.13759459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942Ab1BRAdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 19:33:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6B95924C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 16:34:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a respin of the route cache deletion patch, with some minor
cleanups that become possible only afterwards.

Enjoy.
