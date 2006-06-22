From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 01:57:28 -0700 (PDT)
Message-ID: <20060622.015728.59653992.davem@davemloft.net>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57500
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932472AbWFVI53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:57:29 -0400
To: swise@opengridcomputing.com
In-Reply-To: <20060621184519.10425.69175.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 21 Jun 2006 13:45:19 -0500

> This patch implements a mechanism that allows interested clients to
> register for notification of certain network events.

We have a generic network event notification facility called
netlink, please use it and extend it for your needs if necessary.
