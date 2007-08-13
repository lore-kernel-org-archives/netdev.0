From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 03:32:33 -0700
Message-ID: <200708130332.33737.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130315.08382.phillips@phunq.net> <20070813102255.GN23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813102255.GN23758@kernel.dk>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 03:22, Jens Axboe wrote:
> I never compared the bio to struct page, I'd obviously agree that
> shrinking struct page was a worthy goal and that it'd be ok to uglify
> some code to do that. The same isn't true for struct bio.

I thought I just said that.

Regards,

Daniel
