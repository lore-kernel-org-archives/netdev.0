From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Sat, 04 Apr 2009 16:51:30 -0700 (PDT)
Message-ID: <20090404.165130.63988510.davem@davemloft.net>
References: <1238778120-8132-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755168AbZDDXvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:51:41 -0400
In-Reply-To: <1238778120-8132-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri,  3 Apr 2009 09:02:00 -0800

> Based on original patch by Ben Hutchings <ben@decadent.org.uk> and
> Bastian Blank <waldi@debian.org>, with the following main changes:
> 
> Separated the mips firmware and rv2p firmware into different files
> to make it easier to update them separately.
> 
> Added some code to fixup the rv2p code with run-time information
> such as PAGE_SIZE.
> 
> Update version to 2.0.0.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
