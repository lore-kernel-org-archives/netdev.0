From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 5/7] ieee80211: export symbol ieee80211_api_version
Date: Mon, 21 Aug 2006 08:27:21 -0400
Message-ID: <20060821122715.GB30051@tuxdriver.com>
References: <20060821033340.GA4802@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:19727 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965078AbWHUM2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 08:28:01 -0400
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20060821033340.GA4802@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 11:33:40AM +0800, Zhu Yi wrote:
> Export this symbol so that wireless drivers can check the running IEEE80211
> API version dynamically.

The sole purpose of this would seem to be supporting out-of-stream
driver development.  Is there some other use that I am overlooking?

I'm sorry, but we just can't/won't take patches that exist solely
for that.  A much better would be for ongoing driver development to
be conducted solely upstream.

John
-- 
John W. Linville
linville@tuxdriver.com
