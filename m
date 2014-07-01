From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 2/2] openvswitch: introduce rtnl ops stub
Date: Tue, 01 Jul 2014 14:40:07 -0700 (PDT)
Message-ID: <20140701.144007.270038393926559969.davem@davemloft.net>
References: <1403769506-9212-1-git-send-email-jiri@resnulli.us>
	<1403769506-9212-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, cwang@twopensource.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	david@gibson.dropbear.id.au, sfeldma@cumulusnetworks.com,
	sucheta.chakraborty@qlogic.com, stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbaGAVkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 17:40:09 -0400
In-Reply-To: <1403769506-9212-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 26 Jun 2014 09:58:26 +0200

> This stub now allows userspace to see IFLA_INFO_KIND for ovs master and
> IFLA_INFO_SLAVE_KIND for slave.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
