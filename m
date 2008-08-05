From: Alessandro Guido <alessandro.guido@gmail.com>
Subject: "e100_probe: Error clearing wake event" when booting 2.6.27-rc1
Date: Tue, 5 Aug 2008 17:30:26 +0200
Message-ID: <200808051730.27599.alessandro.guido@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:12677 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757502AbYHEPa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 11:30:58 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2297487fkq.5
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 08:30:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[please cc me on replies]

I'm getting this error message when booting my laptop.

The commit that causes this is:

commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Mon Jul 7 03:34:48 2008 +0200

    PCI ACPI: Rework PCI handling of wake-up

[very long commit message snipped]

Should I ignore that?
