From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter mask for ACK packets off?
Date: Tue, 03 Jan 2012 07:18:35 -0500
Message-ID: <1325593115.7219.36.camel@denise.theartistscloset.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:61886 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668Ab2ACMSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 07:18:41 -0500
In-Reply-To: <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 10:36 +0100, Dave Taht wrote:
<snip>
> I'd go into more detail, but after what I hope are the final two
> fixes to sfq and qfq land in the net-next kernel (after some more
> testing), I like to think I have a more valid approach than this
> in the works, but that too will require some more development
> and testing.
> 
> http://www.teklibre.com/~d/bloat/pfifo_fast_vs_sfq_qfq_linear.png
> 
<snip>
Hmmm . . . certainly shattered my concerns about replacing pfifo_fast
with SFQ! Thanks - John
