From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Mon, 15 Sep 2003 22:41:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915224119.454578a7.davem@redhat.com>
References: <20030913055033.GB94744@gaz.sfgoth.com>
	<20030913093559.A23840@electric-eye.fr.zoreil.com>
	<20030913080252.GE94744@gaz.sfgoth.com>
	<20030913110353.B23840@electric-eye.fr.zoreil.com>
	<20030913201559.GI94744@gaz.sfgoth.com>
	<20030914125549.A7790@electric-eye.fr.zoreil.com>
	<20030914112628.GD42531@gaz.sfgoth.com>
	<20030915155652.3e5e89a0.davem@redhat.com>
	<20030916031355.GC7982@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030916031355.GC7982@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 20:13:55 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> How about something like the following.  It expands the comment but turns
> that bit of code into an inline function so we onlt have to explain it
> once.

Looks good, applied.
