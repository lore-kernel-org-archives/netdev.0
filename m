From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 0/2] skbedit cleanup
Date: Sat, 21 Dec 2013 16:38:35 -0500
Message-ID: <1387661917-29520-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:49739 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098Ab3LUVjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 16:39:11 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so4644647iej.40
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 13:39:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These changes make skbedit behave similar to other actions
when printing stats and participating in an action chain for
a single flow

Jamal Hadi Salim (2):
  [Iproute2: actions] skbedit to default to pipe
  [Iproute2: actions] skbedit print missing metadata

 tc/m_skbedit.c |    7 +++++++
 1 file changed, 7 insertions(+)

-- 
1.7.9.5
