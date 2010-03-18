From: thomas yang <lampsu@gmail.com>
Subject: [iproute2] iproute2 question
Date: Thu, 18 Mar 2010 17:02:16 +0800
Message-ID: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:57333 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab0CRJCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 05:02:17 -0400
Received: by pzk32 with SMTP id 32so1360112pzk.4
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 02:02:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Linux router R (has some interfaces)  use the table "main" as default
routing table to route packets.  If  some link connected to R failed,
I want to use another table "backup_tbl" to route packets; if the
broken link repaired , go back to use table "main"  .  How to do this?
