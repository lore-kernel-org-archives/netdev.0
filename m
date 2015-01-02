From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] geneve: Add Geneve GRO support
Date: Fri, 02 Jan 2015 15:47:05 -0500 (EST)
Message-ID: <20150102.154705.1895776696459852312.davem@davemloft.net>
References: <1419995416-29987-1-git-send-email-jesse@nicira.com>
	<1419995416-29987-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joestringer@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbABUrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:47:07 -0500
In-Reply-To: <1419995416-29987-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 30 Dec 2014 19:10:16 -0800

> From: Joe Stringer <joestringer@nicira.com>
> 
> This results in an approximately 30% increase in throughput
> when handling encapsulated bulk traffic.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, looks great, thanks Jesse.
