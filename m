From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 16:52:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526165238.60eae8ff.davem@redhat.com>
References: <B1508D50A0692F42B217C22C02D849727FEDB8@NT-IRVA-0741.brcm.ad.broadcom.com>
	<20040526160443.GD4557@sgi.com>
	<20040526110121.657f2d42.davem@redhat.com>
	<20040526234732.GA5958@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040526234732.GA5958@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 May 2004 09:47:33 +1000
Greg Banks <gnb@sgi.com> wrote:

> If we can show a performance improvement on our hardware, would you
> accept a patch to enable host send rings on our hardware only?

Did you read my other email?  I already made the change globally
in my sources.  tg3 will always use host send rings now.
