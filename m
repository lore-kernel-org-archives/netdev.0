From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make LLC2 compile with PROC_FS=n
Date: Mon, 20 Oct 2003 22:32:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020223237.31854ab5.davem@redhat.com>
References: <Pine.GSO.4.58.0310171452540.13905@blinky>
	<20031020101607.76e02647.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: noah@caltech.edu, acme@conectiva.com.br, rddunlap@osdl.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031020101607.76e02647.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003 10:16:07 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Why make up a whole separate llc_proc.h file for two prototypes? 
> Put them on the end of llc.h

I definitely prefer this version of the fix.

Since Arnaldo appears to be busy, I'll apply this.

Thanks Noah and Stephen.
