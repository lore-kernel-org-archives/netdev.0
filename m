From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Thu, 2 Jan 2003 18:26:06 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030102182606.A32722@almesberger.net>
References: <20021224225040.A22201@almesberger.net> <200301020138.EAA32608@sex.inr.ac.ru> <20030102030858.E1363@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <20030102030858.E1363@almesberger.net>; from wa@almesberger.net on Thu, Jan 02, 2003 at 03:08:58AM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I wrote:
> I searched around but didn't spot anything. A pointer would be
> welcome, thanks !

I think I found it. Is it "The Rate-Halving Algorithm for TCP Congestion
Control", section 5.14, "Application of Bounding Paremeters" (sic!) ?
http://www.psc.edu/networking/ftp/papers/draft-ratehalving.txt

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
