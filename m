From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/2]: HFSC: Fix requeueing
Date: Thu, 18 Mar 2004 20:41:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318204157.23314086.davem@redhat.com>
References: <4059D327.40300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4059D327.40300@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 17:49:43 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes requeueing in HFSC. Requeued packets are kept in a
> high-priority queue which is always dequeued first.

Applied, thanks Patrick.
