From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6] af_mpls: add null dev check in find_outdev
Date: Tue, 04 Aug 2015 06:35:14 -0700
Message-ID: <55C0BF92.3020908@cumulusnetworks.com>
References: <1438695246-22575-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, ebiederm@xmission.com,
	rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33795 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933077AbbHDNfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 09:35:16 -0400
Received: by pawu10 with SMTP id u10so8894566paw.1
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 06:35:16 -0700 (PDT)
In-Reply-To: <1438695246-22575-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8/4/15, 6:34 AM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds null dev check for the 'cfg->rc_via_table ==
> NEIGH_LINK_TABLE or dev_get_by_index() failed' case
>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
pls ignore ..., resubmitting..
