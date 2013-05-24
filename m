From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Can purge ifenslave from upstream kernel
Date: Fri, 24 May 2013 11:37:11 -0700
Message-ID: <20130524113711.0aa51a86@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:55019 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755968Ab3EXShR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 14:37:17 -0400
Received: by mail-ie0-f171.google.com with SMTP id e10so410276iej.30
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 11:37:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since bonding supports configuration via iproute (netlink) and sysfs, I think
it is time to purge the old ifenslave code out of Documentation/networking
and update the documentation.

Any volunteers?
