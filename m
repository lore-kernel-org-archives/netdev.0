From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] macvlan: fix typo in macvlan_print_opt()
Date: Sat, 31 Aug 2013 10:32:20 -0700
Message-ID: <20130831103220.2b18c8b5@nehalam.linuxnetplumber.net>
References: <1377762628-28843-1-git-send-email-ljaenicke@innominate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lutz Jaenicke <ljaenicke@innominate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47731 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab3HaRcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 13:32:23 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so3129047pbb.33
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 10:32:22 -0700 (PDT)
In-Reply-To: <1377762628-28843-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Aug 2013 09:50:28 +0200
Lutz Jaenicke <ljaenicke@innominate.com> wrote:

> The mode information is contained in IFLA_MACVLAN_MODE instead
> of IFLA_VLAN_ID (both evaluating to "1" in their enums).
> 
> Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>

Thanks applied.
