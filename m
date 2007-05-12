From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: default y idiocy
Date: Sat, 12 May 2007 20:58:47 +0100
Message-ID: <46461C77.5040404@simon.arlott.org.uk>
References: <20070512182343.GO4629@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20070512182343.GO4629@kernel.dk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/07 19:23, Jens Axboe wrote:
> Hi,
> 
> This has bothered me for a long time, and it just seems to be getting
> worse. Can people please STOP defaulting non-essential stuff to 'y'?
> Grrr.

Is there a reason why various 10/100/1000Mbit network cards are 'y' too?
There's even a default SCSI 'm' that seems to be completely hidden from 
the menu too (CONFIG_SCSI_WAIT_SCAN). It depends on SCSI but I can't 
disable SCSI...

-- 
Simon Arlott
