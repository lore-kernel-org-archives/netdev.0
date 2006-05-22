From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless-dev updated
Date: Mon, 22 May 2006 22:32:23 +0200
Message-ID: <20060522223223.1f18ccb7@logostar.upir.cz>
References: <20060519191549.GF30177@tuxdriver.com>
	<20060522144214.02f0adb2@griffin.suse.cz>
	<20060522195545.GF13964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:3712 "EHLO cela.cz")
	by vger.kernel.org with ESMTP id S1751007AbWEVUb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 16:31:27 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060522195545.GF13964@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, 22 May 2006 15:55:50 -0400, John W. Linville wrote:
> On Mon, May 22, 2006 at 02:42:14PM +0200, Jiri Benc wrote:
> > This patch is wrong, it uses incorrect ioctl number (collides with
> > userspace MLME).
> 
> Since you had posted that in the same thread, I had presumed that
> you had accounted for that... :-)

I realized it only after I had added Jouni's patch to my tree :-(

> As you wish...you know I love to shake-up the history in my trees... :-(

Sorry for that. I will try to send pull requests more frequently. Hm,
hopefully. Maybe I will be stuck with those #$@ sysfs patches forever.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
