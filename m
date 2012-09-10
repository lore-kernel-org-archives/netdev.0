From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Who maintains and handles patches for drivers/net/phy/ ?
Date: Mon, 10 Sep 2012 09:20:11 +0200
Message-ID: <504D94AB.7070404@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:20316 "EHLO mailhub1.si.c-s.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706Ab2IJHUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 03:20:13 -0400
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 18BF51C83F1
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 08:20:09 +0200 (CEST)
Received: from mailhub1.si.c-s.fr ([192.168.12.234])
	by localhost (mailhub1.c-s.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8vTA93c5WmqW for <netdev@vger.kernel.org>;
	Mon, 10 Sep 2012 08:20:09 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 0434F1C83F0
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 08:20:09 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 83B6CC7393
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 09:20:12 +0200 (CEST)
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id IAeDIFFGIUny for <netdev@vger.kernel.org>;
	Mon, 10 Sep 2012 09:20:12 +0200 (CEST)
Received: from [127.0.0.1] (unknown [172.25.231.59])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 47065C7391
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 09:20:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MAINTAINER file doesn't include any maintainer for drivers/net/phy/
Section NETWORKING DRIVERS doesn't refer to anyone.

I have a patch for the Intel LXT phy driver. I submitted it to the list 
a few weeks ago but didn't get any feedback at all.
Who shall I contact to get my patch taken into account ?

Regards
Christophe
