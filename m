From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 5/10] cxgb3 - scatter gather engine
Date: Fri, 8 Dec 2006 11:08:41 -0800
Message-ID: <20061208110841.6dc27120@localhost>
References: <20061208032725.8538.60025.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50530 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426061AbWLHTKA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 14:10:00 -0500
To: Divy Le Ray <None@chelsio.com>
In-Reply-To: <20061208032725.8538.60025.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NAPI code in the cxgb2 driver was a mess (see patch today), don't know if
cxgb3 could use the similar brain surgery..


