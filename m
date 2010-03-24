From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2010-03-23 - IPv6 warnings...
Date: Wed, 24 Mar 2010 18:42:26 -0400
Message-ID: <20100324184226.3bf42d8f.akpm@linux-foundation.org>
References: <201003232301.o2NN1bms031050@imap1.linux-foundation.org>
	<12096.1269481001@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12096.1269481001@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Mar 2010 21:36:41 -0400 Valdis.Kletnieks@vt.edu wrote:

> On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
> > The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> 
> Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
> prefix arrives via a PPP VPN connection. This happened about 20-25 seconds
> after I launched pppd.

Yes, thanks, I get the same - it doesn't seem to break anything.  It
also happens some time after boot has completed, presumably when I do
something, but I haven't looked into what "something" is.  It's
certainly not as complex as a PPP VPN connection.

The net guys are crunching on it.
