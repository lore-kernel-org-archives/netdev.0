From: Kevin Wilson <wkevils@gmail.com>
Subject: iproute2 neighboring
Date: Fri, 4 Nov 2011 13:11:08 +0200
Message-ID: <CAGXs5wUEiS-vpdsCDoyva2Vg9XKBmbJgoPVOXUXD0u9+PzXH=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:43787 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab1KDLLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 07:11:08 -0400
Received: by vws1 with SMTP id 1so1734704vws.19
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2011 04:11:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
It seems to me that "ip -6 neigh show" does not show multicast entries from
IPv6 neighboring  table. Is there a reason for this ?
rgs,
Kevin
