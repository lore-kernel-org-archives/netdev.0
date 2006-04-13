From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Thu, 13 Apr 2006 10:30:48 -0700
Message-ID: <20060413103048.64f8d0f0@localhost.localdomain>
References: <20060413091423.GA28623@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27537 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751032AbWDMRbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 13:31:04 -0400
To: yi.zhu@intel.com
In-Reply-To: <20060413091423.GA28623@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please get rid of the debug config option. Make the debug code, default
off and be low enough impact that everyone can ship with it.
