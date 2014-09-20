From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH v1.1 0/2] PTP related changes for fm10k
Date: Sat, 20 Sep 2014 23:52:31 +0200
Message-ID: <20140920215229.GC5258@netboy>
References: <20140920170138.25490.40273.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:60573 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaITVwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:52:36 -0400
Received: by mail-wg0-f41.google.com with SMTP id k14so899014wgh.24
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 14:52:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140920170138.25490.40273.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks ok to me, and removing the timecounter stuff makes sense.
For these two patches,

Acked-by: Richard Cochran <richardcochran@gmail.com>
