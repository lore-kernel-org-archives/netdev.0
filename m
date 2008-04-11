From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: [PATCH] [IPV6]: bug 10437:  MSG_ERRQUEUE messages do not pass to
 connected raw sockets
Date: Fri, 11 Apr 2008 15:02:52 +0400
Message-ID: <47FF455C.2070205@odu.neva.ru>
References: <bug-10437-10286@http.bugzilla.kernel.org/> <20080410103444.d7309e1f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:47698 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759293AbYDKLCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 07:02:53 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTP id 3DAE4780EE
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 15:02:52 +0400 (MSD)
In-Reply-To: <20080410103444.d7309e1f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Dmitry, I'd suggest that you send the patch via email to
> netdev@vger.kernel.org 

OK, resend

> and to YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>.
>   
It seems that I cannot reach this e-mail address from my country :( (some terrible antispam?)



The small patch to fix bug #10437 .

See description of the bug at 
http://bugzilla.kernel.org/show_bug.cgi?id=10437


Dmitry Butskoy
http://www.fedoraproject.org/wiki/DmitryButskoy
