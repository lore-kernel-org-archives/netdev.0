From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 4/5]: remove unneccessary checks for qdisc->dev
Date: Wed, 4 Aug 2004 09:44:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804094438.687d4234.davem@redhat.com>
References: <410FAE65.6010802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FAE65.6010802@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:25:25 +0200
Patrick McHardy <kaber@trash.net> wrote:

> qdisc->dev is always valid, this patch removes a couple of unneccessary 
> checks.

Looks good, applied.
