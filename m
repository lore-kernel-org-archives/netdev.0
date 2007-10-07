From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sun, 7 Oct 2007 12:39:18 -0700
Message-ID: <86802c440710071239x28c41db2hca6dd7c5bb3c411c@mail.gmail.com>
References: <20071006151250.GA17020@havoc.gtf.org>
	 <4708F194.7080303@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ayaz Abdulla" <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:20702 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbXJGTjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 15:39:18 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1404659wah
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2007 12:39:18 -0700 (PDT)
In-Reply-To: <4708F194.7080303@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/7/07, Jeff Garzik <jeff@garzik.org> wrote:
> Jeff Garzik wrote:
> > The 'fe-lock' branch of
> > git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git fe-lock
> OK, I've successfully tested patches 1-5 on an AMD64 system with
>
> 00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)

need to test that with mcp55 based, that will use MSI.

YH
