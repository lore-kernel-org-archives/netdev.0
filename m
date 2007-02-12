From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] spidernet: move medium variable into card struct
Date: Mon, 12 Feb 2007 17:28:04 -0600
Message-ID: <20070212232804.GE923@austin.ibm.com>
References: <200702122137.15309.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, benh@kernel.crashing.org,
	James K Lewis <jim@jklewis.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:47636 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030491AbXBLX2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 18:28:06 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1CNS6hp005148
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 18:28:06 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1CNS5xL531610
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:28:05 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1CNS4YQ016466
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 16:28:05 -0700
Content-Disposition: inline
In-Reply-To: <200702122137.15309.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 09:37:15PM +0100, Jens Osterkamp wrote:
> This moves the medium variable into the spidernet card structure.
> It renames the GMII_ variables to BCM54XX specific ones.
> 
> Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

Boot-tested the patch, it works for me

Acked-by: Linas Vepstas <linas@austin.ibm.com>

