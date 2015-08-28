From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] rhashtable-test: add cond_resched() to thread test
Date: Fri, 28 Aug 2015 13:03:36 +0200
Message-ID: <20150828110336.GH32206@pox.localdomain>
References: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36569 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbH1LDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 07:03:38 -0400
Received: by wicfv10 with SMTP id fv10so5157958wic.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 04:03:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440757685-14241-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 at 12:28pm, Phil Sutter wrote:
> This should fix for soft lockup bugs triggered on slow systems.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Thomas Graf <tgraf@suug.ch>
