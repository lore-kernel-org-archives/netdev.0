From: Andrew <nitr0@seti.kr.ua>
Subject: VIA Velocity 6130 - is it supported?
Date: Wed, 08 Sep 2010 23:01:14 +0300
Message-ID: <4C87EB8A.6050503@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.seti.kr.ua ([91.202.132.4]:56984 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753682Ab0IHUtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 16:49:31 -0400
Received: from [91.202.133.246] (helo=[172.19.32.10])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1OtQpP-0000y2-MV
	for netdev@vger.kernel.org; Wed, 08 Sep 2010 23:01:08 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Hi all.
I tried to run VT6130 on 2.6.35.2 kernel - but as result I have eth 
device with MAC ff:ff:ff:ff:ff:ff, that can't be upped - RNETLINK 
returns a lot of errors 'can't set address".
Is this device supported by kernel drivers?
