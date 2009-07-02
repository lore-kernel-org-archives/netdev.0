From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: can I detect that the system was wake-on-lan booted?
Date: Thu, 02 Jul 2009 09:25:17 +0200
Message-ID: <4A4C60DD.3080304@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.syneticon.net ([78.111.66.105]:47694 "EHLO
	mx03.syneticon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbZGBHYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:24:50 -0400
Received: from localhost (filter1.syneticon.net [192.168.113.83])
	by mx03.syneticon.net (Postfix) with ESMTP id 4C07C35E20
	for <netdev@vger.kernel.org>; Thu,  2 Jul 2009 09:24:51 +0200 (CEST)
Received: from mx03.syneticon.net ([192.168.113.84])
	by localhost (mx03.syneticon.net [192.168.113.83]) (amavisd-new, port 10025)
	with ESMTP id btzMR3vTE4+J for <netdev@vger.kernel.org>;
	Thu,  2 Jul 2009 09:24:49 +0200 (CEST)
Received: from [192.168.10.145] (koln-4db4154b.pool.einsundeins.de [77.180.21.75])
	by mx03.syneticon.net (Postfix) with ESMTPSA
	for <netdev@vger.kernel.org>; Thu,  2 Jul 2009 09:24:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it possible to detect if the system (x86_32 or x86_64 kernel) was 
booted with wake-on-lan?

I would like to make different system startups, accordingly (enable X if 
normal power-on or reboot; do not enable X if PC turned on with 
wake-on-lan).


-- 
Tomasz Chmielewski
http://wpkg.org
