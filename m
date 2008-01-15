From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Not understand some in htb_do_events function
Date: Tue, 15 Jan 2008 13:11:50 +0300
Message-ID: <478C86E6.3050508@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33867 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbYAOKL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 05:11:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id B5C7CA6C2C2
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 13:11:57 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7KmgumM6Fjcs for <netdev@vger.kernel.org>;
	Tue, 15 Jan 2008 13:11:50 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id CF78EA6C185
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 13:11:50 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
I have many messages like "htb: too many events !" in dmesg.

Try to see code and find that function try do 500 events at call.
Hm... may anyone ask why 500? Why its not dynamic value based on 
performance of PC?

Thanks for answers.

