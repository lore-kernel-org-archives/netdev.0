From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: HFSC packet scheduler
Date: Thu, 29 Jan 2004 12:13:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040129121347.5b715047.davem@redhat.com>
References: <401923B8.7030909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <401923B8.7030909@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 Jan 2004 16:16:08 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This is the 2.6 version of HFSC. Changes to last patch:
> 
> - don't crash on user error (non-work-conserving inner qdisc)
> - trailing whitespace cleanup

Ok applied.  I did a s/u_intX_t/uX/ in sch_hfsc.c, I hope you don't mind.
