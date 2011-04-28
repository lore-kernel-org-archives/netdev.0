From: David Miller <davem@davemloft.net>
Subject: Re: [NEXT PATCH 2/3] qlcnic: support rcv ring configuration
 through ethtool
Date: Thu, 28 Apr 2011 13:44:18 -0700 (PDT)
Message-ID: <20110428.134418.229764087.davem@davemloft.net>
References: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
	<1303951426-4341-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, sucheta.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753158Ab1D1Uov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:44:51 -0400
In-Reply-To: <1303951426-4341-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed, 27 Apr 2011 17:43:45 -0700

> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> o Support ethtool command ETHTOOL_GCHANNELS and ETHTOOL_SCHANNELS.
> o Number of rcv rings configuration depend upon number of msix vector.
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Please address Ben's feedback and resubmit this.
