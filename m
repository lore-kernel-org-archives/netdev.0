From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] SH: fix typos in Ether platform data
Date: Thu, 22 Aug 2013 02:15:16 +0400
Message-ID: <201308220215.16463.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:57387 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab3HUWPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 18:15:11 -0400
Received: by mail-lb0-f169.google.com with SMTP id u10so1119395lbi.28
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 15:15:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Shamefully, I have fat fingered in both patches fixing Ether support on SH
platforms and I didn't bother to compile test them at least with the ARM
compiler I have at hand (although one of the files turned out to not really be
compilable by it). Here's 2 patches fixing the typos, they are against David
Miller's 'net-next.git'.

[1/2] SH7619: fix typo in Ether platform data
[2/2] SolutionEngine7724: fix typo in Ether platform data

WBR, Sergei
