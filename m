From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mark some potential candidates
 __read_mostly
Date: Fri, 30 Jan 2015 17:58:54 -0800 (PST)
Message-ID: <20150130.175854.1971558623391875024.davem@davemloft.net>
References: <1422530103-23869-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbbAaB64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:58:56 -0500
In-Reply-To: <1422530103-23869-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 29 Jan 2015 12:15:03 +0100

> They are all either written once or extremly rarely (e.g. from init
> code), so we can move them to the .data..read_mostly section.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
