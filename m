From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] e1000e: Add pm_qos header
Date: Tue, 12 May 2015 23:22:29 -0400 (EDT)
Message-ID: <20150512.232229.1979995423254165727.davem@davemloft.net>
References: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jeffrey.t.kirsher@intel.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934292AbbEMDWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:22:31 -0400
In-Reply-To: <1431445020-25235-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue, 12 May 2015 09:36:59 -0600

> Commit e2c6544829f moved pm_qos_req to e1000_adapter. Add the header file
> that defines the struct.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
