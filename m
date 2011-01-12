From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2 1/2] net_device: add support for network device
 groups
Date: Wed, 12 Jan 2011 10:40:18 -0500
Message-ID: <1294846818.2129.3.camel@mojatatu>
References: <1294763724-9927-1-git-send-email-ddvlad@rosedu.org>
	 <1294763724-9927-2-git-send-email-ddvlad@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:49058 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276Ab1ALPkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 10:40:22 -0500
Received: by vws16 with SMTP id 16so181789vws.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 07:40:21 -0800 (PST)
In-Reply-To: <1294763724-9927-2-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-11 at 18:35 +0200, Vlad Dogaru wrote:
> Net devices can now be grouped, enabling simpler manipulation from
> userspace. This patch adds a group field to the net_device strucure, as
                                                             ^^^^^
typo

> well as rtnetlink support to query and modify it.
> 


> +	unsigned int group;

Should that be int?

cheers,
jamal

