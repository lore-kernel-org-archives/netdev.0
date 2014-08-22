From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bonding: create netlink event when bonding
 option is changed
Date: Fri, 22 Aug 2014 12:34:24 -0700 (PDT)
Message-ID: <20140822.123424.1711272961101178700.davem@davemloft.net>
References: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, nikolay@redhat.com, dingtianhong@huawei.com,
	sfeldma@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaHVTeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 15:34:25 -0400
In-Reply-To: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 19 Aug 2014 16:02:12 +0200

> Userspace needs to be notified if one changes some option.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
