From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: appletalk/cops_probe BUG: soft lockup - CPU#1 stuck for 23s!
Date: Sun, 29 Jul 2012 14:00:03 +0100
Message-ID: <20120729140003.6fa483d2@ultron>
References: <20120729124022.GA16748@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Joe Perches <joe@perches.com>,
	"kernel-janitors@vger.kernel..." <kernel-janitors@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:51939 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab2G2M7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 08:59:08 -0400
In-Reply-To: <20120729124022.GA16748@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Jul 2012 20:40:22 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> Hi,
> 
> This is probably a rather old bug, triggered while doing randconfig
> boot tests in kvm:

I'm not sure testing old devices with no safe probe method is useful in
this context ?

Alan
