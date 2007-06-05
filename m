From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Tue, 5 Jun 2007 15:03:03 -0700
Message-ID: <20070605150303.5249e0c0@freepuppy>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141256.15650.37514.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, Patrick McHardy <kaber@trash.net>,
	ebiederm@xmission.com, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37933 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933582AbXFEWQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 18:16:43 -0400
In-Reply-To: <20070605141256.15650.37514.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  5 Jun 2007 16:12:57 +0200 (MEST)
Patrick McHardy <kaber@trash.net> wrote:

> [RTNETLINK]: Link creation API
> 
> Add rtnetlink API for creating, changing and deleting software devices.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 

If you want I'll extend existing bridge netlink to use these.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
