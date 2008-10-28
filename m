From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/6] netns: configurable number of initial network	namespaces
Date: Tue, 28 Oct 2008 18:51:52 +0100
Message-ID: <49075138.80808@trash.net>
References: <20081028174659.GF8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: Vivien Chappelier <vivien.chappelier@thomson.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37627 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbYJ1Rvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:51:55 -0400
In-Reply-To: <20081028174659.GF8471@thomson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivien Chappelier wrote:
> This allows the creation of more than one network namespace at boot time.

I'm wondering, what is the advantage over creating them manually?
They have to be configured by userspace to be useful anyway, don't
they?

