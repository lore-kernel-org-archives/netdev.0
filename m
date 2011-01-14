From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3 2/2] netlink: support setting devgroup parameters
Date: Fri, 14 Jan 2011 10:10:32 -0500
Message-ID: <1295017832.2225.32.camel@mojatatu>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
	 <1294997911-13866-3-git-send-email-ddvlad@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36088 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757652Ab1ANPKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 10:10:33 -0500
Received: by vws16 with SMTP id 16so1043894vws.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 07:10:33 -0800 (PST)
In-Reply-To: <1294997911-13866-3-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-14 at 11:38 +0200, Vlad Dogaru wrote:
> If a rtnetlink request specifies a negative or zero ifindex and has no
> interface name attribute, but has a group attribute, then the chenges
> are made to all the interfaces belonging to the specified group.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal

