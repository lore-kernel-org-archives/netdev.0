From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] wan: convert taskqueues to workqueues
Date: Sat, 20 Sep 2003 00:32:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920003227.47d400be.davem@redhat.com>
References: <20030919114641.43d57172.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20030919114641.43d57172.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2003 11:46:41 -0700
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> This patch converts (or attempts to convert) drivers/net/wan/*
> from task queues to the workqueue API, plus a few other small
> cleanups.

Looks good to me, applied.
