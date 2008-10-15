From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Wed, 15 Oct 2008 07:19:37 +0000
Message-ID: <20081015071936.GB4215@ff.dom.local>
References: <20081014095246.GA10804@ff.dom.local> <48F4CBBA.7070004@intel.com> <20081014191554.GA2953@ami.dom.local> <48F502FA.4040004@intel.com> <20081015064522.GA4215@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:33221 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbYJOHTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 03:19:43 -0400
Received: by ey-out-2122.google.com with SMTP id 6so927628eyi.37
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2008 00:19:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081015064522.GA4215@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2008 at 06:45:22AM +0000, Jarek Poplawski wrote:
...
> Without this __netif_schedule() call we should expect at least higher

Should be:
"Even without this __netif_schedule() call..."

Jarek P.
