From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: bridge-utils : bridge fdb replace undocumented
Date: Thu, 8 Jan 2015 10:22:02 -0800
Message-ID: <20150108102202.4fb6dd99@urahara>
References: <CAAfiWQqCv9=nFRNuxHPb+hRVbNywiEN_bQJHaxXc29hka0iUaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mathieu Rohon <mathieu.rohon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:59785 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbbAHSWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 13:22:12 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so12620211pdi.7
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 10:22:12 -0800 (PST)
In-Reply-To: <CAAfiWQqCv9=nFRNuxHPb+hRVbNywiEN_bQJHaxXc29hka0iUaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Jan 2015 13:52:01 +0100
Mathieu Rohon <mathieu.rohon@gmail.com> wrote:

> Hi,
> 
> the command :
> #bridge fdb replace
> 
> can be useful to replace a learned Mac address by a static one. We'd
> like to use this command to solve an openstack bug :
> https://bugs.launchpad.net/neutron/+bug/1367999
> 
> However it is not documented in the manpage of bridge-utilis version 1.5.9.
> 
> Also, I don't know what is the minimum version to have this features.
> 
> regards,
> Mathieu

Bridge command is part of iproute2 not bridge-utils.
