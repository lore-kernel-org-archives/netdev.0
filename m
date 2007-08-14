From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23 1/3]S2IO: Making MSIX as default intr_type
Date: Tue, 14 Aug 2007 00:58:39 -0400
Message-ID: <46C1367F.4080605@garzik.org>
References: <Pine.GSO.4.10.10708060525530.4004-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52418 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S940196AbXHNE6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 00:58:43 -0400
In-Reply-To: <Pine.GSO.4.10.10708060525530.4004-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied 1-3 to #upstream (2.6.23), but we'll want to look into why NAPI 
and MSI-X aren't playing well for you.  especially look at NAPI changes 
in net-2.6.24.

	Jeff



