From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH 2.6] repost, fix sysctl breakage during network
 device renaming, for ipv4
Date: Mon, 1 Sep 2003 09:41:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901094127.6a0f6878.davem@redhat.com>
References: <20030901164624.GA26886@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Aloni <da-x@gmx.net>
In-Reply-To: <20030901164624.GA26886@callisto.yi.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 19:46:24 +0300
Dan Aloni <da-x@gmx.net> wrote:

> Can you please take a look and comment?

I commented already and I said "putting a private copy
of a generic function like strdup() in the middle of
the networking code is inappropriate."
