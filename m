From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH V8 01/13] time: Introduce timekeeping_inject_offset
Date: Thu, 6 Jan 2011 23:00:17 +0100
Message-ID: <201101062300.17289.arnd@arndb.de>
References: <cover.1293820862.git.richard.cochran@omicron.at> <15a12892b0bfc17327d2b3a7695c81fbe6f34337.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: John Stultz <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <15a12892b0bfc17327d2b3a7695c81fbe6f34337.1293820862.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 31 December 2010, John Stultz <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This adds a kernel-internal timekeeping interface to add or subtract

Note that this is not the correct way to submit a patch from someone else.
You should instead use your own name and email address as the sender,
and have "From: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>" as the first line in
the body of the email. You also need to add your own "Signed-off-by: 
Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>" line below the S-o-b from
John.

Using git-send-email plus git-format-patch will gets this right if
the commit was done correctly in your own git tree. If you prefer to
use a different set of tools, you need to watch out for these details
yourself.

	Arnd
