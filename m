From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 21:51:31 -0400 (EDT)
Message-ID: <20150315.215131.243360484962703197.davem@davemloft.net>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbCPBvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 21:51:33 -0400
In-Reply-To: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 15 Mar 2015 18:45:18 -0700

> v2:
> 
>  - Per Simon's review, squash some of the dependent commits into one to
>    make series git bisect safe.
> 
> v1:
> 
> Per discussions at netconf, move switchdev ndo ops to a new swdev_ops to
> keep ndo namespace clean and maintain switchdev-related ops into one place.
> 
> There are no functional changes here; just shuffling ops around for better
> organization.

This looks a lot better, series applied.
