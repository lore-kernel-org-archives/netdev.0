From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Subject: [regression], wlcore, wl1835mod random firmware load failures
Date: Thu, 23 Mar 2017 07:27:40 +0200
Message-ID: <daeab501-eb1b-499d-c209-8f061526cfbc@nextfour.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0073.outbound.protection.outlook.com ([104.47.0.73]:45696
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752196AbdCWHca (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 03:32:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With 4.11-rc+ we have seen randomly :
 wlcore: ERROR could not allocate memory for the firmware

when trying to load a firmware bundled in the kernel at boot time. Any ideas?
