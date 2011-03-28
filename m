From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH]: linux-firmware: add myri10ge firmware
Date: Mon, 28 Mar 2011 09:43:20 -0400
Message-ID: <4D909078.1020002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51175 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab1C1NnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 09:43:24 -0400
Received: by vws1 with SMTP id 1so2263184vws.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 06:43:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have prepared a binary diff (hopefully correctly this time)
which adds the myri10ge firmware to the linux-firmware tree.
Due to the large size, I've uploaded the patch to the following URL
rather than attaching it:

http://www.myri.com/staff/gallatin/fw/0001-linux-firmware-add-myri10ge-firmware.patch

Thanks to sgruszka@redhat.com for teaching me how to properly prepare
the patch.


Drew
