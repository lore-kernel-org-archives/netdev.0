From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Fri, 04 Sep 2009 09:24:30 -0300
Message-ID: <1252067070.6172.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from embedded.ufcg.edu.br ([150.165.63.2]:60804 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756792AbZIDMfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 08:35:07 -0400
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

