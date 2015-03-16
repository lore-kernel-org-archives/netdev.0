From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] switchdev: add swdev ops
Date: Mon, 16 Mar 2015 00:29:02 -0400 (EDT)
Message-ID: <20150316.002902.1391131308595530043.davem@davemloft.net>
References: <1426478836-60788-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbbCPE3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:29:04 -0400
In-Reply-To: <1426478836-60788-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 15 Mar 2015 21:07:13 -0700

> v3:
> 
>  - Fix missing include for DSA build
> 
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

It builds, ship it! :-)

Applied, thanks.
