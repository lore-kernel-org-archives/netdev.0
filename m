From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Wed, 06 Jun 2007 17:39:22 +0200
Message-ID: <4666D52A.6090109@trash.net>
References: <4666CEAA.8010903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56498 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764851AbXFFPju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 11:39:50 -0400
In-Reply-To: <4666CEAA.8010903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:

> +MODULE_DESCRIPTION("Virtual Ethernet Tunnel");
> +MODULE_LICENSE("GPL v2");

This seems to be missing MODULE_ALIAS_RTNL_LINK("veth");
