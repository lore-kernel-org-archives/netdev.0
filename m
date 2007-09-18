From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in
 setup_net
Date: Mon, 17 Sep 2007 18:58:30 -0700 (PDT)
Message-ID: <20070917.185830.91315570.davem@davemloft.net>
References: <46EE5EDD.1030005@openvz.org>
	<m1ir69tp7l.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754301AbXIRB6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 21:58:34 -0400
In-Reply-To: <m1ir69tp7l.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 17 Sep 2007 07:07:42 -0600

> Pavel if you are going down this route.  Could you look at
> cleanup_net as well.  The reverse walk there could probably
> benefit from being list_for_each_entry_reverse.

Pavel please resubmit this work after everything has been
resolved, thanks.

If you have already, please resend as I don't have a copy.
