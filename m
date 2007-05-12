From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: default y idiocy
Date: Sat, 12 May 2007 22:05:16 +0200
Message-ID: <20070512200516.GS4629@kernel.dk>
References: <20070512182343.GO4629@kernel.dk> <46461C77.5040404@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46461C77.5040404@simon.arlott.org.uk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 12 2007, Simon Arlott wrote:
> On 12/05/07 19:23, Jens Axboe wrote:
> >Hi,
> >
> >This has bothered me for a long time, and it just seems to be getting
> >worse. Can people please STOP defaulting non-essential stuff to 'y'?
> >Grrr.
> 
> Is there a reason why various 10/100/1000Mbit network cards are 'y' too?
> There's even a default SCSI 'm' that seems to be completely hidden from 
> the menu too (CONFIG_SCSI_WAIT_SCAN). It depends on SCSI but I can't 
> disable SCSI...

For the exact same (wrong) reason that the other menuconfig changes did
it, I suppose. Need fixing, too.

-- 
Jens Axboe

