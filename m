From: Samuel Ortiz <sameo@linux.intel.com>
Subject: [GIT] [4.2] 2nd NFC update
Date: Thu, 18 Jun 2015 22:57:06 +0200
Message-ID: <20150618205706.GA16707@ribalta.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux NFC <linux-nfc@lists.01.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3426 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259AbbFRU53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 16:57:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This is a follow up fix for a typo that I introduced while cleaning
the 1st 4.2 NFC pull request patches.

The following changes since commit d0dcad8bd32a34aa85bcbd5d2033658cb3964377:

  NFC: nfcmrvl: set PB_BAIL_OUT at setup (2015-06-13 00:08:55 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/nfc-next.git tags/nfc-next-4.2-2

for you to fetch changes up to fb77ff4f43990dc91926ce2704036a547482544e:

  NFC: nci: fix mistake in uart generic driver (2015-06-15 18:10:37 +0200)

----------------------------------------------------------------
Vincent Cuissard (1):
      NFC: nci: fix mistake in uart generic driver

 net/nfc/nci/uart.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
