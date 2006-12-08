From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 0/10] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Fri, 8 Dec 2006 10:35:57 -0800
Message-ID: <20061208103557.38c3dd9b@localhost>
References: <4578DB2F.4010204@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47229 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760832AbWLHSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 13:36:50 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <4578DB2F.4010204@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor style stuff (that can be fixed later).
1) /* C style comments */ are preferred over // C++ style
2) Please use C99 style structure initializers especially for OS
   interface structures like ops for MII.
