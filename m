From: Sedat Cakir <sedat.cakirim@gmail.com>
Subject: TSO support
Date: Tue, 27 Sep 2011 10:19:21 +0300
Message-ID: <CAG+4w0mNdSwwQMH7+DSGUzMUrqjE_v7M55EP8Ug6JxytuJsN7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50880 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab1I0HTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 03:19:21 -0400
Received: by qyk30 with SMTP id 30so618878qyk.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 00:19:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are adding the TCP Segmentation offload (TSO) support to the device
driver and the hardware. I am wondering: Can Linux subsystem supports
the use of IP options and TCP options? If so then which options (e.g
SACK processing for TCP)? Do we need any implementation in the NIC to
manage TCP/IP options?

Thanks,
Sedat
