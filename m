From: Jan Braunisch <x@r6.se>
Subject: Small error on web page
Date: Fri, 9 May 2008 19:42:56 +0200
Message-ID: <200805091942.56749.x@r6.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-2-sn2.hy.skanova.net ([81.228.8.180]:54192 "EHLO
	av9-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbYEISKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 14:10:20 -0400
Received: from smtp4-1-sn2.hy.skanova.net (smtp4-1-sn2.hy.skanova.net [81.228.8.92])
	by av9-2-sn2.hy.skanova.net (Postfix) with ESMTP id 6D47137EA1
	for <netdev@vger.kernel.org>; Fri,  9 May 2008 19:42:57 +0200 (CEST)
Received: from d2.ollbox.skanova.net (90-228-231-223-no126.tbcn.telia.com [90.228.231.223])
	by smtp4-1-sn2.hy.skanova.net (Postfix) with ESMTP id 65D2837E46
	for <netdev@vger.kernel.org>; Fri,  9 May 2008 19:42:57 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

http://www.linux-foundation.org/en/Net:Netem says that 2^32 = 0.0000000232%.
That's obviously wrong :) I think it should be 2^(-32).
