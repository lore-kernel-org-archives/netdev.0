From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24 0/3]: TCP tweaks
Date: Mon, 24 Sep 2007 12:04:05 +0300
Message-ID: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43127 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbXIXJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 05:04:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here are some minor tweaks to recent net-2.6.24 changes, more or
less mandatory. The first one is the most important one because
if the not-supposed-to-happen case occurs, TCP would be left to
an inconsistent state. As regards the second, I'm fine with
either way. The third one's MIB for FRTO is sort of nice to have
but definately not mandatory. I'm leaving decision about those
two to you if you're fine with them feel free to apply :-). 
          
-- 
 i.


