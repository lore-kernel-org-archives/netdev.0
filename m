From: nn6eumtr <nn6eumtr@gmail.com>
Subject: PACKET_LOSS socket option for packet_mmap
Date: Mon, 14 May 2012 00:10:58 -0400
Message-ID: <4FB085D2.3010308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:43851 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2ENEKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 00:10:48 -0400
Received: by qcro28 with SMTP id o28so3057314qcr.19
        for <netdev@vger.kernel.org>; Sun, 13 May 2012 21:10:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What does the PACKET_LOSS socket option for packet_mmap do?

I've seen some sample code setting the option, but couldn't find an 
explanation of what it does.
