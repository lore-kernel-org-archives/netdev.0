From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3 1/2] net_device: add support for network device
 groups
Date: Fri, 14 Jan 2011 10:10:00 -0500
Message-ID: <1295017800.2225.31.camel@mojatatu>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
	 <1294997911-13866-2-git-send-email-ddvlad@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:63834 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757592Ab1ANPKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 10:10:00 -0500
Received: by qwa26 with SMTP id 26so2810219qwa.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 07:09:59 -0800 (PST)
In-Reply-To: <1294997911-13866-2-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-14 at 11:38 +0200, Vlad Dogaru wrote:
> Net devices can now be grouped, enabling simpler manipulation from
> userspace. This patch adds a group field to the net_device structure, as
> well as rtnetlink support to query and modify it.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Good stuff.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

