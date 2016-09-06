From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [ethtool PATCH v1 0/2] ethtool: add support for 1000BaseX and
 missing 10G link mode
Date: Tue, 6 Sep 2016 16:16:16 -0400
Message-ID: <20160906201614.GE2909@tuxdriver.com>
References: <1472453810-47177-1-git-send-email-vidya@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bwh@kernel.org, davem@davemloft.net,
        decot@googlers.com, roopa@cumulusnetworks.com,
        dustin@cumulusnetworks.com
To: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48704 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934233AbcIFUaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:30:19 -0400
Content-Disposition: inline
In-Reply-To: <1472453810-47177-1-git-send-email-vidya@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 11:56:48PM -0700, Vidya Sagar Ravipati wrote:
> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
> 
> This patchset enhances ethtool link mode bitmap to include
> missing interface modes for 1G/10G speeds
> 
> Vidya Sagar Ravipati (2):
>   ethtool-copy.h:sync with net
>   ethtool: add support for 1000BaseX and missing 10G link mode
> 
>  ethtool-copy.h | 11 +++++++++--
>  ethtool.c      | 19 +++++++++++++++++++
>  2 files changed, 28 insertions(+), 2 deletions(-)
> 
> -- 
> 2.1.4

LGTM -- applied

Would you care to fix-up the man page as well?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
