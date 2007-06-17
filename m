From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: -x qla3xxx* and ifenslave.c to a package
Date: Sun, 17 Jun 2007 12:05:04 +0200
Message-ID: <46750750.80405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:59522 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761046AbXFQKFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 06:05:09 -0400
Received: by mu-out-0910.google.com with SMTP id i10so1810677mue
        for <netdev@vger.kernel.org>; Sun, 17 Jun 2007 03:05:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

Jeff please:

remove the "x" file access permission of:
drivers/net/qla3xxx.c
drivers/net/qla3xxx.h

move Documentation/networking/ifenslave.c to a user
space package(iputils, net-tools, ....)


-thanks-


regards,
