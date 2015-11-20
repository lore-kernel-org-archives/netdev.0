From: Andrew <nitr0@seti.kr.ua>
Subject: Kernel 4.1.12 crash
Date: Fri, 20 Nov 2015 15:58:23 +0200
Message-ID: <564F26FF.3040605@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.seti.kr.ua ([91.202.132.4]:51311 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161118AbbKTN62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 08:58:28 -0500
Received: from [91.226.59.244] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1ZzmCl-0003fY-Vr
	for netdev@vger.kernel.org; Fri, 20 Nov 2015 15:58:25 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

Today some BRASes on 4.1.12 kernel were crashed.

Here's crash traces: http://pastebin.com/p68hNS8R 
http://pastebin.com/36ieRAM2 http://pastebin.com/3BRTVEB6

On 3.2 kernel same hardware works OK, troubles were noticed after kernel 
upgrade.

What additional info is needed?
