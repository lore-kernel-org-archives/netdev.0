From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: ethernet: Fix SGMII unable to switch speed and
 autonego failure
Date: Tue, 15 Nov 2016 12:06:37 -0500 (EST)
Message-ID: <20161115.120637.674417235218492197.davem@redhat.com>
References: <1479114409-20002-1-git-send-email-ho.jia.jie@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ho.jia.jie@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750998AbcKORGk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 12:06:40 -0500
In-Reply-To: <1479114409-20002-1-git-send-email-ho.jia.jie@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ho.jia.jie@intel.com
Date: Mon, 14 Nov 2016 17:06:49 +0800

> From: Jia Jie Ho <ho.jia.jie@intel.com>
> 
> TSE PCS SGMII ethernet has an issue where switching speed doesn't work
> caused by a faulty register macro offset. This fixes the issue.
> 
> Signed-off-by: Jia Jie Ho <ho.jia.jie@intel.com>

Applied.
