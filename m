From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] zd1211rw: fix a double include
Date: Fri, 19 Oct 2007 23:06:34 -0400
Message-ID: <471970BA.3080001@garzik.org>
References: <20071018220946.GH8510@tuxdriver.com> <11927586853636-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Holger Schurig <hs4233@mail.mn-solutions.de>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43545 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161AbXJTDGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 23:06:36 -0400
In-Reply-To: <11927586853636-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> From: Holger Schurig <hs4233@mail.mn-solutions.de>
> 
> This patch removes all double includes of the same file. This
> makes scripts/checkincludes.pl happy.
> 
> Signed-off-by: Holger Schurig <hs4233@mail.mn-solutions.de>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> Jeff, I missed the zd1211rw hunk of the "double includes" patch.  Could
> you apply this one manually?

this does not appear to be needed, after the pull


