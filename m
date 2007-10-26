From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'fixes-davem' branch of wireless-2.6
Date: Fri, 26 Oct 2007 00:11:31 -0400
Message-ID: <20071026041131.GD14080@tuxdriver.com>
References: <20071026031033.GC14080@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3186 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbXJZELr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 00:11:47 -0400
Content-Disposition: inline
In-Reply-To: <20071026031033.GC14080@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 25, 2007 at 11:10:33PM -0400, John W. Linville wrote:

> The following changes since commit c9927c2bf4f45bb85e8b502ab3fb79ad6483c244:
>   Linus Torvalds (1):
>         Linux 2.6.24-rc1
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem
> 
> Jeff Garzik (1):
>       mac80211: fix warning created by BIT()

Hmmm...this doesn't actually seem to fix the warning -- oops!

Disregard this request, I'll apply Johannes' fix instead and send
another pull request.

John
-- 
John W. Linville
linville@tuxdriver.com
