From: Adayadil Thomas <adayadil.thomas@gmail.com>
Subject: Connection tracking and vlan
Date: Thu, 29 Oct 2009 11:43:23 -0400
Message-ID: <fb7befa20910290843k12ab8ba6hbecb69bda8652ae0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:65436 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbZJ2PnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 11:43:18 -0400
Received: by vws30 with SMTP id 30so297923vws.33
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 08:43:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings!

If two connections have same 5 tuple, src ip, dst ip, src port, dst
port, protocol(tcp/udp)
but on different vlans (different vlan id), does the conntrack separate these ?

I am using kernel version 2.6.20; the conntrack tuple structure do not
seem to have vlan information.

Any information is much appreciated.

Thanks
