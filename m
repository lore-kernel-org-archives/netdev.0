From: "Noah J. Misch" <noah@caltech.edu>
Subject: Re: [PATCH] Make LLC2 compile with PROC_FS=n
Date: Tue, 21 Oct 2003 04:13:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.58.0310210401470.26573@clyde>
References: <Pine.GSO.4.58.0310171452540.13905@blinky>
 <20031020101607.76e02647.shemminger@osdl.org> <20031020223237.31854ab5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031020223237.31854ab5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003, David S. Miller wrote:

> On Mon, 20 Oct 2003 10:16:07 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
>
> > Why make up a whole separate llc_proc.h file for two prototypes?
> > Put them on the end of llc.h
>
> I definitely prefer this version of the fix.

I agree completely.  Thanks, Stephen.

> Since Arnaldo appears to be busy, I'll apply this.

Great.
