From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: restore multicast list on resume and other ops
Date: Thu, 13 Sep 2007 00:02:59 -0400
Message-ID: <46E8B673.5040001@garzik.org>
References: <200708312010.38276.timo@tiwe.de> <20070905165619.093513af@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Timo_Weing=E4rtner?= <timo@tiwe.de>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40670 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbXIMEDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:03:04 -0400
In-Reply-To: <20070905165619.093513af@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Need to restore multicast settings on resume and after 'ethtool -r'.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied to #upstream-fixes


