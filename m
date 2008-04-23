From: Raz <raziebe@gmail.com>
Subject: Question of Network 1Gbps Intel Packet Split
Date: Wed, 23 Apr 2008 09:17:58 +0300
Message-ID: <5d96567b0804222317i7c6f900wc8a9164423610976@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:61961 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbYDWGR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 02:17:59 -0400
Received: by wa-out-1112.google.com with SMTP id m16so4400731waf.23
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 23:17:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
I have been wondering whether anyone can answer the bellow two questions.
Intel PCI-E 1Gbps cards have a feature for rx mode : "packet split".
so:
1. Is it true that when "packet split" is enabled, **ALL** packets
will be splitted , header / payload ?
2. Is is true that there is exactly one fragment when splitted ?

Thank you
Raz
