From: Max Matveev <makc@redhat.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and net.sctp.sctp_wmem
 tunables
Date: Tue, 5 Jul 2011 11:58:13 +1000
Message-ID: <19986.28597.369890.164459@regina.usersys.redhat.com>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
	<4E126A1E.7070300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab1GEB6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 21:58:18 -0400
In-Reply-To: <4E126A1E.7070300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jul 2011 09:34:22 +0800, Shan Wei wrote:

 shanwei> Max Matveev wrote, at 06/20/2011 04:08 PM:
 >> sctp does not use second and third ("default" and "max") values
 >> of sctp_(r|w)mem tunables. 

 shanwei> Avoid confusion, but you introduced new confusion.
 shanwei> Hope that you also can correct your changelog in next version. 
Done - just send v2 of the patch.

max
