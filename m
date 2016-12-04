From: domingo montoya <reach.domingomontoya@gmail.com>
Subject: mlx5 search flow table
Date: Sun, 4 Dec 2016 09:01:38 +0530
Message-ID: <CAOYAsN=oaTF+oS4BZPcn2daoLdtYYzBz=ozbRnv6fLMwzbD_Ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:35145 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbcLDDbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 22:31:40 -0500
Received: by mail-wj0-f177.google.com with SMTP id v7so262787313wjy.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 19:31:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was wondering if there was any way I could search what flow tables,
flow groups, flow rules exist for mlx5_core driver.


I am aware of the QUERY_* commands but I need to provide a valid
tableId or groupId to retrieve the information.

Let's say because of any bug, one of the flow table or flow group or
flow rule gets orphaned i.e., doesn't get deleted.

Is there any way to know that information, so as to explicity delete
those rules, tables, groups at a later point?

Thanks a lot!

Best Regards,
Domingo
