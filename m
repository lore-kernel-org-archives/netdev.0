From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCHSET] Extended matches and basic classifier
Date: Tue, 25 Jan 2005 21:52:49 -0800
Message-ID: <20050125215249.2aec06d7.davem@davemloft.net>
References: <20050123230012.GB23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050123230012.GB23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 00:00:12 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> This patchset adds the ematch API, the ematches cmp, nbyte, u32, meta,
> and the basic classifier. It doesn't touch any existing code.

I'm busy merging pure bug fixes, so I'll try to review this
one soon.  Likely it will go into 2.6.12, although I may try
to sneak it into the pending 2.6.11 tree.
