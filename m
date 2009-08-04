From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 04 Aug 2009 15:24:27 -0700
Message-ID: <87ab2fdxpg.fsf@caffeine.danplanet.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
	<1249331463-11887-6-git-send-email-danms@us.ibm.com>
	<20090804205241.GF10275@us.ibm.com>
	<878whzl2cs.fsf@caffeine.danplanet.com>
	<20090804211742.GC13499@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:39990 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751400AbZHDWY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 18:24:27 -0400
In-Reply-To: <20090804211742.GC13499@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 4 Aug 2009 16\:17\:42 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> I don't understand.  Which pid?

I meant the socket's peercred, which includes the pid of the process
that opened it, but that clearly won't work... :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
