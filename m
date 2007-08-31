From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: tcp user timeout option
Date: Fri, 31 Aug 2007 11:23:25 +0300
Message-ID: <200708311123.25559.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:50837 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754699AbXHaIWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 04:22:54 -0400
Received: from localhost (localhost [127.0.0.1])
	by creon.otaverkko.fi (Postfix) with ESMTP id 1FB22256D6A
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 11:22:53 +0300 (EEST)
Received: from argo.otaverkko.fi (argo.otaverkko.fi [212.68.0.2])
	by creon.otaverkko.fi (Postfix) with ESMTP id BF74E256D5B
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 11:22:50 +0300 (EEST)
Received: from vetar.pc.hiit.fi (vetar.pc.hiit.fi [128.214.113.230])
	by argo.otaverkko.fi (Postfix) with ESMTP id 163F725ED06
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 11:22:50 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Does anybody know of any effort put into implementing support for the TCP user 
timeout option in Linux?

The related draft:
http://www.ietf.org/internet-drafts/draft-ietf-tcpm-tcp-uto-06.txt

Basically its a per-connection parameter which says how long data can remain 
unacknowledged before the connection is closed.

br, j
