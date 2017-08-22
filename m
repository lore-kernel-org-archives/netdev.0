From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: make ptp_clock_info const
Date: Tue, 22 Aug 2017 09:50:12 +0200
Message-ID: <20170822075012.pcgr3dfau4duv3gt@localhost>
References: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
 <20170822062730.u2zj7qumzjcl4f6o@localhost>
 <CAOH+1jGDjGusOCYv+S4P9LGq9vbnYtMF1-NfnyjfGYiM2ugGpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOH+1jGDjGusOCYv+S4P9LGq9vbnYtMF1-NfnyjfGYiM2ugGpg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 12:06:23PM +0530, Bhumika Goyal wrote:
> By testing I meant that they have been checked by the compiler. I
> haven't run the code on a hardware or some test data.

Yes, compiling is good enough for this change.

Thanks,
Richard

> > Acked-by: Richard Cochran <richardcochran@gmail.com>
