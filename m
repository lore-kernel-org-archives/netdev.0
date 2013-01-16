From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] vmxnet3: patches
Date: Wed, 16 Jan 2013 14:41:46 -0500 (EST)
Message-ID: <20130116.144146.1449675471247791596.davem@davemloft.net>
References: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3APTlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 14:41:53 -0500
In-Reply-To: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 15 Jan 2013 09:28:25 -0800

> Minor VMXNET3 cleanup found while reviewing driver.

Series applied, thanks Stephen.

I agree with Ben that we should have a standard copy of that
default RSS key somewhere, but that's a follow-on rather
than a blocker for your changes.

Thanks.
