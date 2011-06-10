From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] inetpeer not namespace ready
Date: Fri, 10 Jun 2011 06:44:50 +0200
Message-ID: <1307681090.3210.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52065 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab1FJEoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 00:44:54 -0400
Received: by wya21 with SMTP id 21so1589381wya.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 21:44:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Shouldnt we make inetpeer cache namespace aware ?

Same destination IP can be used differently in two different namespaces.

Thanks


