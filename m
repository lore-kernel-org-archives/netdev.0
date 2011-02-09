From: kaber@trash.net
Subject: [PATCH 0/1] netfilter: netfilter fixes
Date: Wed,  9 Feb 2011 15:39:28 +0100
Message-ID: <1297262369-26393-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is a single netfilter fix for net-2.6.git, fixing use of conntrack
templates when TCP conntrack kills the current conntrack in TIME_WAIT state
in order to have the conntrack core create a fresh one, from Pablo.

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

