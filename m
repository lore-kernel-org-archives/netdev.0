From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Introducing 2014 and updating maintainer
Date: Mon, 06 Jan 2014 01:30:29 -0500 (EST)
Message-ID: <20140106.013029.1195007411131993187.davem@davemloft.net>
References: <1388925273-12512-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbaAFGab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 01:30:31 -0500
In-Reply-To: <1388925273-12512-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is absolutely not appropriate to bump the date in all of these
source files, and for that to be the sole and only change.

Bump the dates when you make real other changes to these files,
and no sooner.

Furthermore, this is doubly not legitimate for the 'net' tree
which should only be getting real and serious bug fixes right
now.
