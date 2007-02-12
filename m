From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/4] spidernet: support for Celleb
Date: Mon, 12 Feb 2007 17:49:59 -0600
Message-ID: <20070212234959.GF923@austin.ibm.com>
References: <200702070849.l178nvGC005341@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, jens@de.ibm.com, linuxppc-dev@ozlabs.org,
	jim@jklewis.com, netdev@vger.kernel.org
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56369 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030518AbXBLXuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:50:04 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1CNo1Eg023152
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 18:50:01 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1CNo1Vc390338
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:50:01 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1CNo07h017949
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:50:00 -0700
Content-Disposition: inline
In-Reply-To: <200702070849.l178nvGC005341@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 07, 2007 at 05:49:50PM +0900, Ishizaki Kou wrote:
> This is a revised spidernet patch set based on
> netdev-2.6.git#upstream.

Tested this series of patches together with Jen's "version 3" patch,
it worked for me. Code looks reasonable.  Thus

Acked-by: Linas Vepstas <linas@austin.ibm.com>

I'm somewhat unclear as to whethr I should be doing 

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

instead.

--linas
