From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] expose stack entry function
Date: Thu, 28 Sep 2017 08:43:31 -0700 (PDT)
Message-ID: <20170928.084331.924575925867572935.davem@davemloft.net>
References: <cover.1506590878.git.amine.kherbouche@6wind.com>
        <d34f8440be3e1d735c694c6899c5a8b14e9a70ea.1506590878.git.amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com,
        equinox@diac24.net
To: amine.kherbouche@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753149AbdI1Pnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 11:43:32 -0400
In-Reply-To: <d34f8440be3e1d735c694c6899c5a8b14e9a70ea.1506590878.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amine Kherbouche <amine.kherbouche@6wind.com>
Date: Thu, 28 Sep 2017 11:34:19 +0200

> Exporting mpls_forward() function to be able to be called from elsewhere
> such as MPLSoverGRE in the next commit.
> 
> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

You need to resubmit this series with this patch having a proper
subsystem prefix in the Subject line, as pointed out by another
reviewer.

Thanks.
