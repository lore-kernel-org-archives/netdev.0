From: David Miller <davem@davemloft.net>
Subject: Re: netns : fix kernel panic in timewait socket destruction
Date: Mon, 08 Sep 2008 13:17:41 -0700 (PDT)
Message-ID: <20080908.131741.109958037.davem@davemloft.net>
References: <48C0EFB5.6080503@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, ebiederm@xmission.com
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752618AbYIHURr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 16:17:47 -0400
In-Reply-To: <48C0EFB5.6080503@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 05 Sep 2008 10:37:09 +0200

> netns : fix kernel panic in timewait socket destruction

Applied, thanks.
