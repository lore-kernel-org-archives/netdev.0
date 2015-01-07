From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] libnetlink: add parse_rtattr_one_nested
 helper
Date: Wed, 7 Jan 2015 15:15:13 -0800
Message-ID: <20150107151513.592c568d@urahara>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thaller@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35404 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbbAGXPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:15:32 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so7414481pde.12
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:15:31 -0800 (PST)
In-Reply-To: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  6 Jan 2015 17:23:45 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Sometimes, it is more convenient to get only one specific nested attribute by
> type. For example for IFLA_AF_SPEC where type is address family (AF_INET6).
> So add this helper for this purpose.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

This one applies.
