From: thomas yang <lampsu@gmail.com>
Subject: [netfilter / iptables] question
Date: Fri, 2 Apr 2010 00:44:44 +0800
Message-ID: <v2if4f837ab1004010944yd08c37c5u23d6f2d07df7ccc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jengelh@medozas.de
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38935 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758607Ab0DAQop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 12:44:45 -0400
Received: by pwi5 with SMTP id 5so1180354pwi.19
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 09:44:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I want to copy/ clone a  sk_buff  *skb  to  *skb2  on my Linux router,
  then transmit both  skb2   and  skb  .

How to do this with   netfilter hook function  / iptables  ?



--
Tom
