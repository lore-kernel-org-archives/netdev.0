From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: add sysfs entry for device group
Date: Tue, 25 Jan 2011 14:41:06 +1000
Message-ID: <20110125144106.1cbd12b0@s6510>
References: <1295876249-15634-1-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59578 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752998Ab1AYElL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 23:41:11 -0500
In-Reply-To: <1295876249-15634-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jan 2011 15:37:29 +0200
Vlad Dogaru <ddvlad@rosedu.org> wrote:

> The group of a network device can be queried or changed from userspace
> using sysfs.
> 
> For example, considering sysfs mounted in /sys, one can change the group
> that interface lo belongs to:
> 	echo 1 > /sys/class/net/lo/group
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
