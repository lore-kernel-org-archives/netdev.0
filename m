From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] netlink: add missing netlink message types to
 selinux perm table
Date: Wed, 05 Dec 2012 11:23:35 +0800
Message-ID: <1354677815.28951.8.camel@cr0>
References: <1354593208-21939-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab2LEDXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 22:23:44 -0500
In-Reply-To: <1354593208-21939-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 11:53 +0800, Cong Wang wrote:
> RTM_NEWNETCONF and RTM_GETNETCONF are missing in this table.

This patch has conflicts with "v3 bridge: export multicast database via
netlink", please drop this for now, I will resend it later.

Thanks.
