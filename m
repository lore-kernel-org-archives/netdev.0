From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] Make LLC2 compile with PROC_FS=n
Date: Wed, 22 Oct 2003 18:18:16 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031022211815.GA10112@conectiva.com.br>
References: <Pine.GSO.4.58.0310171452540.13905@blinky> <20031020101607.76e02647.shemminger@osdl.org> <20031020223237.31854ab5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, noah@caltech.edu,
        rddunlap@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031020223237.31854ab5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Oct 20, 2003 at 10:32:37PM -0700, David S. Miller escreveu:
> On Mon, 20 Oct 2003 10:16:07 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Why make up a whole separate llc_proc.h file for two prototypes? 
> > Put them on the end of llc.h
> 
> I definitely prefer this version of the fix.
> 
> Since Arnaldo appears to be busy, I'll apply this.
> 
> Thanks Noah and Stephen.

Thanks a lot, I'm back from Europe, hope to become more active again.

Regards,

- Arnaldo
