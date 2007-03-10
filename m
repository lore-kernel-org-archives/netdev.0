From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCHES 0/11] skb->mac.raw refactorings
Date: Sat, 10 Mar 2007 13:45:44 -0300
Message-ID: <39e6f6c70703100845i1ebfdbf7l842511cb8ec8e97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:56103 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767716AbXCJQpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 11:45:47 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1698470uga
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2007 08:45:45 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

         Paving the way for turning the layer headers offsets, to
shrink struct sk_buff on 64bits (and perhaps on 32 bits too).

         Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22.git

- Arnaldo
