From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 5/5]: remove noop_qdisc assignments in destroy
 functions
Date: Wed, 4 Aug 2004 09:47:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804094702.6aa191a4.davem@redhat.com>
References: <410FAE82.7070604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FAE82.7070604@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:25:54 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch removes useless noop_qdisc assignments in multiple qdiscs destroy
> functions, the memory where the pointer is stored is freed directly 
> after the destroy function.

Applied.
