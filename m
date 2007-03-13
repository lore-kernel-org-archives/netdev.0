From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCHES 0/6] Turn skb->nh into a union of just one member 8)
Date: Mon, 12 Mar 2007 22:27:06 -0300
Message-ID: <39e6f6c70703121827i521e24dbv72dff3ae1d92a268@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:48733 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbXCMB1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 21:27:14 -0400
Received: by ug-out-1314.google.com with SMTP id 44so77684uga
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 18:27:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

          Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

           As the last csets says its just a temporary situation :-)

- Arnaldo
