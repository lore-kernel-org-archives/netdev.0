From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 06/26] rt2x00: compile fix for d80211 update
Date: Sun, 3 Dec 2006 19:19:04 +0100
Message-ID: <200612031919.04580.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:24664 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758799AbWLCSTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:34 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144389nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:34 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix rt2x00 compilation problems due to the d80211 update.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

http://www.mendiosus.nl/rt2x00/06_d80211.diff
