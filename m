From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: couple of software reset bit cleanups
Date: Sun, 24 Apr 2016 23:42:48 +0300
Message-ID: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:34184 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbcDXUmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 16:42:53 -0400
Received: by mail-lf0-f46.google.com with SMTP id j11so105925178lfb.1
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 13:42:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 2 patches against DaveM's 'net-next.git' repo. We clean up
the use of the software reset bits...

[1/2] sh_eth: use EDMR_SRST_GETHER in sh_eth_check_reset()
[2/2] sh_eth: rename ARSTR register bit

MBR, Sergei
