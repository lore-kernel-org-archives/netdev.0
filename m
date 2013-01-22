From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 16/20] drivers/net/wireless/p54: remove depends on
 CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 11:59:12 -0800
Message-ID: <20130122195912.GA31151@kroah.com>
References: <1358879444-25834-17-git-send-email-keescook@chromium.org>
 <201301221937.16916.chunkeey@googlemail.com>
 <CAGXu5jJCQshUntUk7MeZds59B2fa54GnonOz28dM1x2spEEGDg@mail.gmail.com>
 <20130122.141252.781223481145097577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: keescook@chromium.org, chunkeey@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com, kvalo@qca.qualcomm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130122.141252.781223481145097577.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 02:12:52PM -0500, David Miller wrote:
> From: Kees Cook <keescook@chromium.org>
> Date: Tue, 22 Jan 2013 10:40:12 -0800
> 
> > On Tue, Jan 22, 2013 at 10:37 AM, Christian Lamparter
> > <chunkeey@googlemail.com> wrote:
> >> Aren't these patches going through wireless-next
> >> or linux-next?
> > 
> > They can go however it makes things easiest. Greg has offered to carry
> > them in driver-core if Dave doesn't want to carry them in netdev.
> 
> Greg can take these:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, I'll go do that now.

greg k-h
