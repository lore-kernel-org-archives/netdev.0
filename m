From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] bridge FDB ageing time.
Date: Mon, 16 Mar 2015 15:58:05 -0400 (EDT)
Message-ID: <20150316.155805.624305948580536654.davem@davemloft.net>
References: <1426487405-9792-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932927AbbCPT6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:58:07 -0400
In-Reply-To: <1426487405-9792-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I stated, I want you to address the fundamental issue with br_changelink()
before making it even worse with your new feature.

Thanks.
