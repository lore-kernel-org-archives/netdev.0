From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSEC and MPLS priority for 2.6?
Date: Wed, 17 Dec 2003 23:49:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031217234952.31efc004.davem@redhat.com>
References: <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Dec 2003 09:36:15 +0200 (EET)
Pekka Savola <pekkas@netcore.fi> wrote:

> Andrew characterized (or Dave) did the lack of MPLS support as a huge 
> issue for serious IPSEC usage in:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/must-fix/should-fix-7.txt
> [see below]
> 
> .. I don't agree.

You're probably right, it's priority can be decreased.

If the MPLS stuff is ready later in the 2.6.x series though, it
will be very easy to merge safely.
