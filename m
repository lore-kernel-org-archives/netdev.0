From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/2] a few bridge code cleanups
Date: Sat, 04 Jul 2009 10:11:56 +0400
Message-ID: <20090704061156.658235360@openvz.org>
To: shemminger@linux-foundation.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:48104 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbZGDGXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 02:23:20 -0400
Received: by fxm18 with SMTP id 18so2520752fxm.37
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2009 23:23:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

here is a few bridge cleanups - code alignment
and conditional compilation for structure members.

Please review. Hope I didn't miss anything.
Anyway if it breaks someone patch queue --
just drop this series then.

Cyrill
