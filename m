From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 net-next 0/4] update ipvs sysctl document
Date: Mon, 20 Feb 2017 16:31:34 +0800
Message-ID: <1487579498-18967-1-git-send-email-liuhangbin@gmail.com>
References: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Cc: netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Julian Anastasov <ja@ssi.bg>,
        Hangbin Liu <liuhangbin@gmail.com>
To: lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34777 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdBTIcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 03:32:32 -0500
In-Reply-To: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix and add some new ipvs sysctl options. Also use tab instead of
whitespaces to indent the descriptions.

V2: Fix some descriptions based on Julian's advice.

Hangbin Liu (4):
  ipvs: fix sync_threshold description and add sync_refresh_period, sync_retries
  ipvs: Document sysctl sync_qlen_max and sync_sock_size
  ipvs: Document sysctl sync_ports
  ipvs: Document sysctl pmtu_disc

 Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
 1 file changed, 60 insertions(+), 8 deletions(-)

-- 
2.5.5
