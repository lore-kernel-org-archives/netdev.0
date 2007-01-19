From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Thu, 18 Jan 2007 22:10:47 -0500
Message-ID: <45B036B7.8080904@garzik.org>
References: <20070118154801.GB31580@tuxdriver.com> <20070118154906.GC31580@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47769 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964784AbXASDKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:10:51 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070118154906.GC31580@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 10764889c6355cbb335cf0578ce12427475d1a65:
>   Larry Finger (1):
>         bcm43xx: Fix failure to deliver PCI-E interrupts
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

ACK.  Open question of parentage, though:  I just rebased 
netdev-2.6.git#upstream.  Is your wireless-2.6 affected by this rebase?

If not, I will go ahead and pull.

	Jeff



