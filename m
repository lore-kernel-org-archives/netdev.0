From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [2.6.24-mm1] TCP/IPv6 connect() oopses at twothirdsMD4Transform()
Date: Tue, 05 Feb 2008 12:02:24 +0900
Message-ID: <200802050302.m1532OFk007019@www262.sakura.ne.jp>
References: <200802050128.m151ShPX088549@www262.sakura.ne.jp> <20080204173652.0fbe8885.akpm@linux-foundation.org> <1202178600.17934.165.camel@cinder.waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tytso@mit.edu, akpm@linux-foundation.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755309AbYBEDCx@vger.kernel.org>
In-Reply-To: <1202178600.17934.165.camel@cinder.waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

> random: revert braindamage that snuck into checkpatch cleanup
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>

Yes. It solved the oops.

Thank you.
