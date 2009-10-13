From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 13 Oct 2009 14:18:47 -0300
Message-ID: <4AD4B677.4000308@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivocalado@embedded.ufcg.edu.br
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from embedded.ufcg.edu.br ([150.165.63.2]:50303 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760668AbZJMRTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:19:34 -0400
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
http://embedded.ufcg.edu.br/~ivocalado/dccp/patches/patches_tfrc_sp_receiver-v2/tfrc_sp_receiver_01.patch

