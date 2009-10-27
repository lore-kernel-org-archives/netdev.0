From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 v4 0/4] TCPCT part1: cookie option exchange
Date: Tue, 27 Oct 2009 08:11:08 -0400
Message-ID: <4AE6E35C.2050101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:37560 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbZJ0MLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 08:11:08 -0400
Received: by yxe17 with SMTP id 17so49432yxe.33
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 05:11:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated to patch cleanly with recent commits.

Changes from previous version:
* Strongly type otherwise void parameter with empty struct.
* Combined two shorter patches (b + c), dropping update of 2 drivers,
   as nobody has gotten back to me about testing results.
* Added a little Documentation for new sysctl.
