From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: Re: 2.6.9-rc1-mm2
Date: Wed, 1 Sep 2004 01:41:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901014118.45204bcb.akpm@osdl.org>
References: <41351C86.7000704@us.ibm.com>
	<200409010833.i818XPZ04210@owlet.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Lindsley <ricklind@us.ibm.com>
In-Reply-To: <200409010833.i818XPZ04210@owlet.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Lindsley <ricklind@us.ibm.com> wrote:
>
> But considering I ran make oldconfig on this and chose
>  the defaults in each and every case, should I end up with a config that
>  doesn't compile?

No, you shouldn't.  This indicates a Kconfig bug.
