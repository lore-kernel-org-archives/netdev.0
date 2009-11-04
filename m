From: David Miller <davem@davemloft.net>
Subject: Re: CLONE_NEWNET requires CAP_NET_RAW (and the intended
 CAP_SYS_ADMIN)
Date: Wed, 04 Nov 2009 05:33:28 -0800 (PST)
Message-ID: <20091104.053328.156160491.davem@davemloft.net>
References: <1257279352.2891.202.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, acme@redhat.com,
	dwalsh@redhat.com
To: eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40688
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755210AbZKDNdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:33:03 -0500
In-Reply-To: <1257279352.2891.202.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>
Date: Tue, 03 Nov 2009 15:15:52 -0500

> Do people see an issue with me passing kern down to create?

This sounds fine.

> Anyone have problems with me ripping out the half ass unused
> security infrastructure?

If you can simplify it as you describe, indeed this sounds
like a great change to make.
