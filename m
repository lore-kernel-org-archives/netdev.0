From: valentina.giusti@bmw-carit.de
Subject: [PATCH v4 0/2] Add UID/GID info to NFQUEUE
Date: Fri, 20 Dec 2013 17:28:52 +0100
Message-ID: <1387556934-7372-1-git-send-email-valentina.giusti@bmw-carit.de>
Cc: netdev@vger.kernel.org, jpa@google.com, pablo@netfilter.org,
	fw@strnel.de, daniel.wagner@bmw-carit.de
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentina Giusti <valentina.giusti@bmw-carit.de>

Hi,

I corrected the return value of nfqnl_put_sk_uidgid for timewait packets, as
Florian Westphal recommended.

--
BR,
Val
