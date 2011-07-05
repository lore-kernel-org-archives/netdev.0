From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem
 tunables
Date: Tue, 05 Jul 2011 09:34:22 +0800
Message-ID: <4E126A1E.7070300@cn.fujitsu.com>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52065 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752165Ab1GEBdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 21:33:16 -0400
In-Reply-To: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Matveev wrote, at 06/20/2011 04:08 PM:
> sctp does not use second and third ("default" and "max") values
> of sctp_(r|w)mem tunables. 

Avoid confusion, but you introduced new confusion.
Hope that you also can correct your changelog in next version. 


-- 
Best Regards
-----
Shan Wei
