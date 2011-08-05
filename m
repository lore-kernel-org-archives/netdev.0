From: Andrei Warkentin <andreiw@motorola.com>
Subject: Always send NETDEV_CHANGEADDR up
Date: Fri,  5 Aug 2011 16:04:09 -0500
Message-ID: <1312578250-2944-1-git-send-email-andreiw@motorola.com>
References: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:37876 "EHLO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab1HEVLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 17:11:00 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.176.130.20])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p75LBh6x025193
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 17:11:43 -0400 (EDT)
Received: from mail-iy0-f170.google.com (mail-iy0-f170.google.com [209.85.210.170])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p75L8lpY024093
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 17:11:42 -0400 (EDT)
Received: by mail-iy0-f170.google.com with SMTP id 16so4370680iye.29
        for <netdev@vger.kernel.org>; Fri, 05 Aug 2011 14:10:57 -0700 (PDT)
In-Reply-To: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the v4 of the patch, now rebased on net-next-2.6.

ToC:
[PATCHv4] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.

Thank you,
A
