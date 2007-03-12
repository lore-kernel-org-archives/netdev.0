From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCHES 00/18] skb->nh refactorings
Date: Mon, 12 Mar 2007 01:26:18 -0300
Message-ID: <39e6f6c70703112126g16f8c82aq945436f5f3008eeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:50832 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964960AbXCLE0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 00:26:20 -0400
Received: by ug-out-1314.google.com with SMTP id 44so2091317uga
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 21:26:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

          Paving the way for turning the layer headers offsets, to
shrink struct sk_buff on 64bits (and perhaps on 32 bits too), this
time for skb->nh, more on this layer still to come (ip_hdr(), etc).

          Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22.git

Best Regards,

- Arnaldo
