From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Mon, 20 Dec 2004 16:56:16 -0800
Message-ID: <20041220165616.60729dbc.davem@davemloft.net>
References: <20041219203050.GK17998@postel.suug.ch>
	<41C68CEF.3030803@trash.net>
	<1103552215.1048.333.camel@jzny.localdomain>
	<20041221002230.GZ17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041221002230.GZ17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Dec 2004 01:22:30 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Dave, drop this one. I will move indev into the abstraction layer
> i'm going to introduce .11 which will fix the current issues, remove
> the ifdefs and will make removal/replacement much simpler once
> we have metadata match.

OK.
