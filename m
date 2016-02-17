From: Zhen <24281412@qq.com>
Subject: Re: [RFC] net: tcp: null pointer crash in =?utf-8?b?X19pbmV0X3B1dF9wb3J0?=
Date: Wed, 17 Feb 2016 10:01:22 +0000 (UTC)
Message-ID: <loom.20160217T105831-603@post.gmane.org>
References: <1422460613-10782-1-git-send-email-harouth@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:42467 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161285AbcBQLf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 06:35:26 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1aW0Nw-0005Gl-JJ
	for netdev@vger.kernel.org; Wed, 17 Feb 2016 12:35:15 +0100
Received: from 218.249.47.126 ([218.249.47.126])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 12:35:03 +0100
Received: from 24281412 by 218.249.47.126 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 12:35:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harout

I met the same issue.

Is the issue has been fixed by your patch?

Zhen
