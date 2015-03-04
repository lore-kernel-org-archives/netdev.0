From: Stephen Wadeley <swadeley@redhat.com>
Subject: iproute 2, man bridge(8)
Date: Wed, 04 Mar 2015 23:33:50 +0100
Message-ID: <54F7884E.70305@redhat.com>
References: <54F41DF4.1000805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pavlix@pavlix.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbbCDWeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 17:34:05 -0500
In-Reply-To: <54F41DF4.1000805@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dear Stephen

I am proofreading iproute2 man pages.

In bridge.8 , I found this trailing sentence:


Such a history file can be generated with the


git blame reveals:
d04bc300 (Stephen Hemminger 2012-08-01 15:23:49 -0700 530) and dumps
them.  Such a history file can be generated with the

can you check your sources to see what you intended there?


Searching for inspiration, I found this, and more, in the
iproute2/doc/ip-cref.tex file:

Such a history file can be generated with the
rtmon utility. This utility has a command line syntax  similar
to ig monitor.


Thank you

Regards
Stephen

-- 
Stephen Wadeley
Content Author | Red Hat, Inc.
Purkynova 99 | Brno, Czech Republic
