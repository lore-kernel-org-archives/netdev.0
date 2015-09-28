From: Anand Gurram <anandarao.gurram@gmail.com>
Subject: unregister_netdevice warnings when deleting netns
Date: Mon, 28 Sep 2015 13:01:15 +0530
Message-ID: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f195.google.com ([209.85.160.195]:36518 "EHLO
	mail-yk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbbI1HbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:31:19 -0400
Received: by ykdz138 with SMTP id z138so13906062ykd.3
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 00:31:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am currently using kernel version 3.16.7 on a linux switch.
While creating and destroying network namespaces I am observing below logs
on the console
"unregister_netdevice: waiting for lo to become free. Usage count = 1"

Can you please suggest and provide instructions on how to debug this issue.
If any fix already available can you please point me to the link.

Best Regards,
Anand
