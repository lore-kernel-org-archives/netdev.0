From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6] net/bridge: fix trivial sparse errors
Date: Mon, 03 Jan 2011 13:29:27 -0800 (PST)
Message-ID: <20110103.132927.52180227.davem@davemloft.net>
References: <1294088938-6219-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tomas.winkler@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49710
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754503Ab1ACV24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 16:28:56 -0500
In-Reply-To: <1294088938-6219-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Winkler <tomas.winkler@intel.com>
Date: Mon,  3 Jan 2011 23:08:58 +0200

> net/bridge//br_stp_if.c:148:66: warning: conversion of
> net/bridge//br_stp_if.c:148:66:     int to
> net/bridge//br_stp_if.c:148:66:     int enum umh_wait
> 
> net/bridge//netfilter/ebtables.c:1150:30: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>

Applied, thanks Tomas.
