From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: qdisc_restart and pid ?
Date: Tue, 31 Aug 2010 14:39:23 +0530
Message-ID: <AANLkTi=REj5fswCXi9L8+m729dBU67XwMT0Ysmw_WWFO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, kernelnewbies <kernelnewbies@nl.linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:39791 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab0HaJJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 05:09:24 -0400
Received: by gxk23 with SMTP id 23so2384905gxk.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 02:09:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 qdisc_restart(struct net_device *dev)     function as part of kernel thread ?
 i  could do printk in this function for  current->pid ,  pid shows
some user space process .Y it so ?



-Ratheesh
