From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] sch_prio - fix compile warning + some logic
 rearrangement in enqueue
Date: Tue, 29 Jun 2004 14:32:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629143202.3ae7093a.davem@redhat.com>
References: <200406290106.38304.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jamal@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <200406290106.38304.dtor_core@ameritech.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 01:06:36 -0500
Dmitry Torokhov <dtor_core@ameritech.net> wrote:

> When CONFIG_NET_CLS_ACT is not set 'result' variable in prio_classify is
> unused. Also I was looking over the rest of the module and had hard time
> understanding the logic in prio_enqueue - I rearranged it a bit for better
> readability. Plus there are some formatting changes.

Looks good to me, applied.

Thanks Dmitry.
