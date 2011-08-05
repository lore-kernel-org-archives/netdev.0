From: Andrei Warkentin <andreiw@motorola.com>
Subject: Always send NETDEV_CHANGEADDR up
Date: Thu,  4 Aug 2011 21:17:04 -0500
Message-ID: <1312510625-26596-1-git-send-email-andreiw@motorola.com>
References: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og104.obsmtp.com ([64.18.0.178]:38721 "EHLO
	exprod5og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab1HECXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 22:23:52 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.22.94.167])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p752KP8K015743
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:20:25 -0400 (EDT)
Received: from mail-iy0-f170.google.com (mail-iy0-f170.google.com [209.85.210.170])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p752FTAe013960
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2011 22:20:25 -0400 (EDT)
Received: by mail-iy0-f170.google.com with SMTP id 16so2730083iye.29
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 19:23:50 -0700 (PDT)
In-Reply-To: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I apologize for spamming. I removed the meaningless Change-Id from
the patch.

ToC:
[PATCHv3] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.

A
