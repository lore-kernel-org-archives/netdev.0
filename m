From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Remove unnecessary memset in packet schedulers
Date: Mon, 16 Aug 2004 17:22:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816172209.426ab139.davem@redhat.com>
References: <41214C44.5010108@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41214C44.5010108@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004 02:07:32 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch removes some more unnecessary memsets in packet
> schedulers. The qdisc's private data is already set to 0
> in qdisc_create/qdisc_create_dflt.

Applied.
