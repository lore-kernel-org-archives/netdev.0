From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 3/5]: Use double-linked list for dev->qdisc_list
Date: Wed, 4 Aug 2004 13:43:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804134318.34d1fabe.davem@redhat.com>
References: <410FAE42.2050909@trash.net>
	<20040804094308.606f79bd.davem@redhat.com>
	<41113F36.8050204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41113F36.8050204@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 Aug 2004 21:55:34 +0200
Patrick McHardy <kaber@trash.net> wrote:

> >I don't see how this bit is correct:
> >  
> You're right. This patch on top fixes the problem.

Thanks a lot Patrick, applied.
