From: kaber@trash.net
Subject: [PATCH 00/01] netfilter: netfilter fixes
Date: Mon, 14 Feb 2011 17:49:11 +0100
Message-ID: <1297702152-509-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is a single netfilter bugfix for 2.6.38, fixing incorrect
RCU usage in nf_iterate(). Problem noticed by Eric, patch from myself.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!
