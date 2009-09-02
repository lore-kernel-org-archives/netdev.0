From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 1 Sep 2009 23:44:04 -0300
Message-ID: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
References: <cb00fa210909011735l5038c28eofba84b3976902964@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: dccp <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:57204 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbZIBCoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 22:44:22 -0400
In-Reply-To: <cb00fa210909011735l5038c28eofba84b3976902964@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First Patch on TFRC-SP. Does a copy from TFRC and adjust symbols name
with infix "_sp".
Also updates Kconfig and init/exit code. An #ifndef was added to headers that
have commom symbols with TFRC that were not changed, so they don't get
included twice.


Following the rule #8 in Documentation/SubmittingPatches the patch is
stored at http://embedded.ufcg.edu.br/~ivocalado/dccp/patches_tfrc_sp/tfrc_sp_receiver_00.patch
