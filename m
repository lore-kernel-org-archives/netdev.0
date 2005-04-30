From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [RTNETLINK] Cleanup rtnetlink_link tables
Date: Sat, 30 Apr 2005 16:19:17 -0400
Message-ID: <1114892357.8929.151.camel@localhost.localdomain>
References: <20050430195243.GE577@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430195243.GE577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 21:52 +0200, Thomas Graf wrote:
> Converts remaining rtnetlink_link tables to use c99 designated
> initializers to make greping a little bit easier.
> 

Looks nice. You may wanna make net/xfrm/xfrm_user.c equally readble as
well.

cheers,
jamal
