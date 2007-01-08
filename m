From: James Morris <jmorris@namei.org>
Subject: [GIT][Netlabel] Pull request
Date: Mon, 8 Jan 2007 18:24:41 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0701081823390.23051@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:34652 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbXAHXYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 18:24:44 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, please pull per below.



The following changes since commit bf81b46482c0fa8ea638e409d39768ea92a6b0f0:
  Linus Torvalds:
        Linux 2.6.20-rc4

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-davem

Paul Moore:
      NetLabel: correct locking in selinux_netlbl_socket_setsid()
      NetLabel: correct CIPSO tag handling when adding new DOI definitions

 net/netlabel/netlabel_cipso_v4.c |    6 +++---
 security/selinux/ss/services.c   |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)




-- 
James Morris
<jmorris@namei.org>
