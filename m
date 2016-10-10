From: Murali Karicheri <m-karicheri2@ti.com>
Subject: HSR status queries from user space
Date: Mon, 10 Oct 2016 14:13:21 -0400
Message-ID: <57FBDA41.5030306@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <arvid.brodin@alten.se>,
        "netdev@vger.kernel.org >> open list:TI NETCP ETHERNET DRIVER"
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:39935 "EHLO bear.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751702AbcJJSQf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 14:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arvid,

I am investigating the HSR implementation in Linux and wondering if
there is a tool that I can use to query the status of the HSR nodes.
Especially data related to HSR_C_GET_NODE_STATUS and HSR_C_GET_NODE_LIST
commands.

I am able to setup hsr interface using two Ethernet slave interfaces on
my platform and I am able to ping between the two boards. I am looking
to dump the status of the nodes. Could you tell me what tool to use?

ip link command is used to create the hsr interface, but can't find
any tool to dump the node list and status.

Thanks

-- 
Murali Karicheri
Linux Kernel, Keystone
