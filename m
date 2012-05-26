From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: conntrack-tools 1.2.0 release
Date: Sat, 26 May 2012 21:02:33 +0200
Message-ID: <1338058955-5789-1-git-send-email-jengelh@inai.de>
References: <20120526180654.GB31938@1984>
Cc: netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:55491 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab2EZTCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2012 15:02:42 -0400
In-Reply-To: <20120526180654.GB31938@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following changes since commit 318756cd4df1cb7760bf32d3e1d3756c41d1858b:

  add README.nfct (2012-05-26 18:04:11 +0200)

are available in the git repository at:
  git://git.inai.de/conntrack-tools master

Jan Engelhardt (2):
      nfct-extensions/timeout: adjust for changed nfct_timeout_snprintf API
      Update .gitignore

 .gitignore                    |    1 +
 src/.gitignore                |    1 +
 src/nfct-extensions/timeout.c |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)
