From: Cong Wang <cwang@twopensource.com>
Subject: Please queue commit 16c0b164bd24d44db for stable
Date: Mon, 19 May 2014 16:36:08 -0700
Message-ID: <CAHA+R7OQrH9Ay0HRfLFNw4OBzhawqfT8gEW2j0nV5ntzey0p+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35500 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbaESXgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 19:36:10 -0400
Received: by mail-la0-f47.google.com with SMTP id pn19so4678033lab.34
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 16:36:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David


Please queue the following commit for stable (for kernel < 3.6):

commit 16c0b164bd24d44db137693a36b428ba28970c62
Author: Jason Wang <jasowang@redhat.com>
Date:   Wed Aug 15 20:44:27 2012 +0000

    act_mirred: do not drop packets when fails to mirror it


$ git describe --contains 16c0b164bd24d44db
v3.6-rc3~10^2~23

It fixes some real bug.

Thanks!
