From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH][SECURITY] secmark: nul-terminate secdata
Date: Wed, 2 Aug 2006 11:28:01 -0700
Message-ID: <20060802182801.GS2654@sequoia.sous-sol.org>
References: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:7298 "EHLO
	sous-sol.org") by vger.kernel.org with ESMTP id S932124AbWHBS0c
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 14:26:32 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@namei.org) wrote:
> cc'd Chris Wright, as this patch seems like a candidate for the stable 
> tree.

Would be, but I thought secmark went in post 2.6.17.  And I expect Dave
will push this well before 2.6.18.

thanks,
-chris
