From: Oleg <lego12239@yandex.ru>
Subject: CONFIG_NF_CONNTRACK_PROCFS
Date: Sun, 25 Jan 2015 08:51:17 +0300
Message-ID: <20150125055117.GA5586@localhost>
Reply-To: Oleg <lego12239@yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward1h.mail.yandex.net ([84.201.187.146]:51693 "EHLO
	forward1h.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbAYGAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 01:00:01 -0500
Received: from smtp1h.mail.yandex.net (smtp1h.mail.yandex.net [84.201.187.144])
	by forward1h.mail.yandex.net (Yandex) with ESMTP id 0924C9E154B
	for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 08:53:00 +0300 (MSK)
Received: from smtp1h.mail.yandex.net (localhost [127.0.0.1])
	by smtp1h.mail.yandex.net (Yandex) with ESMTP id C176D13410A8
	for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 08:53:00 +0300 (MSK)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi, all.

net/netfilter/nf_conntrack procfs file is marked as obsolete in the recent
kernels. What's wrong with it? Or it's simply a new fashion to replace
simple file interface with anything else?

-- 
Nemanov Oleg
