From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 0/2]: TCP minor
Date: Tue, 11 Dec 2007 13:50:37 +0200
Message-ID: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55023 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbXLKLul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 06:50:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are two TCP patches. The first one removes not so useful
parameter (my avoid GSO skb fragment RFC patch that I'll send
separately right after I get this out depends it). The second
applies cleanly only after the other fack_count fix patch.

--
 i.


