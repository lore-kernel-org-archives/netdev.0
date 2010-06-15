From: kaber@trash.net
Subject: [PATCH 0/1] netfilter: netfilter fixes
Date: Tue, 15 Jun 2010 16:48:04 +0200
Message-ID: <1276613285-4959-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is a single netfilter fix for IPVS from Sven Wegener, fixing a race
condition that might result in an oops.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!
