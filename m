From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: "Close NETIF_F_LLTX race conditions" problem
Date: Sun, 23 Jan 2005 17:33:30 +0100
Message-ID: <20050123163330.GB1917@electric-eye.fr.zoreil.com>
References: <871xcc5oef.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Content-Disposition: inline
In-Reply-To: <871xcc5oef.fsf@devron.myhome.or.jp>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> :
[context if hard_start_xmit changed]
> Umm.. Should we fix the all drivers? Any idea?

The bk-commit mailing-list shows that the culprit has been reverted.

Actually it would probably make sense to audit/change the drivers to
fulfill the requirements for Davem's patch before he resurrects it.

--
Ueimor
