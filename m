From: kaber@trash.net
Subject: [PATCH 0/1] netfilter: netfilter fix
Date: Fri,  2 Jul 2010 13:40:04 +0200
Message-ID: <1278070805-26278-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the following patch for 2.6.35 fixes a dst leak in ip6t_REJECT when
dst->error is set, from Eric Dumazet.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

