From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [SCTP] Do not include ABORT chunk header in the
 notification.
Date: Wed, 09 May 2007 13:52:57 -0700 (PDT)
Message-ID: <20070509.135257.14991605.davem@davemloft.net>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
	<11787398302050-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756544AbXEIUw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 16:52:56 -0400
In-Reply-To: <11787398302050-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  9 May 2007 15:43:50 -0400

> The socket API draft is unclear about whether to include the
> chunk header or not.  Recent discussion on the sctp implementors
> mailing list clarified that the chunk header shouldn't be included,
> but the error parameter header still needs to be there.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
