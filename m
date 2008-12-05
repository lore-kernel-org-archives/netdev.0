From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 0/10]: tcp & more tcp
Date: Fri,  5 Dec 2008 22:58:46 +0200
Message-ID: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58938 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbYLEU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:58:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Some fixes to recent work, and some to pre-historic things.

2) sacktag state struct to avoid ..., *ptr, *ptr2, *ptr3 crazyness

3) Besides that combine some code here and there.

--
 i.


