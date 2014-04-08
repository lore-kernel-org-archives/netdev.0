From: Per Jessen <per@computer.org>
Subject: missing icmp redirects
Date: Tue, 08 Apr 2014 15:49:01 +0200
Message-ID: <5343FE4D.40805@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.spamchek.net ([88.198.198.124]:57202 "EHLO
	outbound.spamchek.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756351AbaDHN4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 09:56:41 -0400
Received: from mail.hostsuisse.com (mail.enidan.com [212.25.14.38])
	by outbound.spamchek.net (Postfix) with ESMTPA id 96484654B9
	for <netdev@vger.kernel.org>; Tue,  8 Apr 2014 15:49:01 +0200 (CEST)
Received: from [192.168.2.114] (io64.local.net [192.168.2.114])
	by mail.hostsuisse.com (Postfix) with ESMTP id 680D946564
	for <netdev@vger.kernel.org>; Tue,  8 Apr 2014 15:49:01 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See complete description here:

https://bugzilla.kernel.org/show_bug.cgi?id=72561

Summary - some ICMP redirects seem to be missing.

Alan suggests I gather some traces, but I'm am unsure of what to trace. 
Suggestions please?


Thanks
Per Jessen
