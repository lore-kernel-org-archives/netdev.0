From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PACTH 1/1] drivers/net/usb: AX88178 100Mbps problem
Date: Thu, 31 Jan 2008 04:41:46 +0000
Message-ID: <1201754506.3297.5.camel@dhollis-lnx.sunera.com>
References: <479DD97A.8020307@hasiru.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Reinin Oyama <lenin@hasiru.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:49770 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbYAaEmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 23:42:22 -0500
Received: from smtp.davehollis.com ([96.228.213.245])
 by vms042.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JVH00JIFRPVIHF2@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 30 Jan 2008 22:41:56 -0600 (CST)
In-reply-to: <479DD97A.8020307@hasiru.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-01-28 at 22:32 +0900, Reinin Oyama wrote:
> Asix 88178 does not work under 100Mbps connection.
> This patch correct the problem.
> kernel version: 2.6.24

Please don't post the patch as a .gz, it's very small so just post it as
text.

Otherwise:

Acked-by: David Hollis <dhollis@davehollis.com>

-- 
David Hollis <dhollis@davehollis.com>

