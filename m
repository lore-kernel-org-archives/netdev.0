From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: notifier chain on br0
Date: Tue, 1 Dec 2009 19:56:03 +0530
Message-ID: <cfeab66d0912010626n43e2a971gdc8a23b976256c56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:48468 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbZLAOZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 09:25:57 -0500
Received: by iwn1 with SMTP id 1so3089223iwn.33
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 06:26:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All ,

 i  have a software bridge br0 on eth0 and eth1 . Can i use NETLINK
sockets to get ip address change notification on br0 .???

Thanks,
Ratheesh
