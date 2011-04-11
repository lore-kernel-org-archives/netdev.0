From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPV4:Removed the unnecessary loops and made
 /proc/net/snmp ouput more readable
Date: Mon, 11 Apr 2011 13:32:45 -0700 (PDT)
Message-ID: <20110411.133245.35050120.davem@davemloft.net>
References: <1302303099-6880-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org
To: sasikanth.v19@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54615
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751534Ab1DKUdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:33:21 -0400
In-Reply-To: <1302303099-6880-1-git-send-email-sasikanth.v19@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasikanth V <sasikanth.v19@gmail.com>
Date: Sat,  9 Apr 2011 04:21:39 +0530

> Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>

Programs parse the output of these files, you cannot change their
layout or else you will break them.
