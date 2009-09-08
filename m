From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 08 Sep 2009 15:28:42 -0300
Message-ID: <4AA6A25A.5040508@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedded.ufcg.edu.br ([150.165.63.2]:18698 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbZIHS2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 14:28:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First Patch on TFRC-SP. Does a copy from TFRC and adjust symbols name
with infix "_sp".
Also updates Kconfig and init/exit code. An #ifndef was added to headers
that
have commom symbols with TFRC that were not changed, so they don't get
included twice.


Following the rule #8 in Documentation/SubmittingPatches the patch is
stored at
http://embedded.ufcg.edu.br/~ivocalado/dccp/patches_tfrc_sp/tfrc_sp_receiver_01.patch

