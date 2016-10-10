From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Redundancy support through PRP?
Date: Mon, 10 Oct 2016 14:34:27 -0400
Message-ID: <57FBDF33.1060606@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39755 "EHLO
        devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbcJJSeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 14:34:22 -0400
Received: from dflxv15.itg.ti.com ([128.247.5.124])
        by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id u9AIYLPP029161
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:34:21 -0500
Received: from DLEE70.ent.ti.com (dlemailx.itg.ti.com [157.170.170.113])
        by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id u9AIYLpF018416
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:34:21 -0500
Received: from [158.218.103.137] (ileax41-snat.itg.ti.com [10.172.224.153])     by
 dflp32.itg.ti.com (8.14.3/8.13.8) with ESMTP id u9AIYKNq021625 for
 <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:34:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

Wondering if there plan to add PRP driver support, like HSR in Linux? AFAIK, PRP
adds trailor to Ethernet frame and is used for Redundancy management like HSR.
So wondering why this is not supported.

Thanks
-- 
Murali Karicheri
Linux Kernel, Keystone
