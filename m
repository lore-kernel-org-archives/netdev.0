From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 patch] atalk compile errors with SYSCTL=n
Date: Wed, 18 Aug 2004 14:47:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818144728.5f5734c4.davem@redhat.com>
References: <20040811224747.GQ26174@fs.tum.de>
	<20040811170101.69c140b6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040811170101.69c140b6@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Aug 2004 17:01:01 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> I prefer to have the CONFIG stuff in the header file.
> Here is an alternative that rearranges to put all function
> prototypes in atalk.h and stubs if necessary. It gets all the #ifdef
> CONFIG_ stuff out of the .c files.

Applied, thanks Stephen.
