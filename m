From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [PATCH 0/4] spidernet: support for Celleb
Date: Mon, 12 Feb 2007 21:40:23 +0100
Message-ID: <200702122140.23370.jens@de.ibm.com>
References: <200702070849.l178nvGC005341@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, jim@jklewis.com,
	linas@austin.ibm.com
To: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:42160 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965389AbXBLUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:40:30 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l1CKeNww050974
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 20:40:23 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1CKeNTH1835056
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 21:40:23 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1CKeMt4018206
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 21:40:23 +0100
In-Reply-To: <200702070849.l178nvGC005341@toshiba.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 February 2007, Ishizaki Kou wrote:
> This is a revised spidernet patch set based on
> netdev-2.6.git#upstream.
> 
> This patch set is merged Jens-san's spidernet patch and works on
> Toshiba Cell reference set (aka Celleb). 
> It requires Jens-san's phy patch
> (http://ozlabs.org/pipermail/linuxppc-dev/2007-February/030987.html).
> 
> Ignore our previos patch set, and try this patch set on Cell Blade,
> please (sorry for asking a lot).

Ishizaki-san,

this patchset works fine for me on the blade now together with my now corrected
sungem update patch and the patch that moves the medium variable into the card structure.

If it also work fine for you I think the patches are finally ready to go in...

Jens
