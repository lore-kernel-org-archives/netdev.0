From: Ajit Warrier <ajit.warrier@gmail.com>
Subject: VLAN bridge patches backported to 2.6.x ?
Date: Sun, 7 Dec 2014 11:25:18 -0800
Message-ID: <CAKrgqt3rMUnkQChTE+_HDiTHx++bp8MWcQ_xp7-Y3tbFznTKMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33562 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbaLGTZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 14:25:19 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so1859450iga.15
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 11:25:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VLAN aware bridge was introduced to the Linux mainline on the 3.x kernels:

http://lwn.net/Articles/538877/

Has this feature been backported to the 2.6.x kernels by anybody ? The
official linux 2.6.32.64 does not have this feature.

Regards,

Ajit.
