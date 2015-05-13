From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [oss-security] [PATCH 0/4] ozwpan: Four remote packet-of-death vulnerabilities
Date: Wed, 13 May 2015 20:48:31 +0200
Message-ID: <CAHmME9pL6kU5D9YNZdDMHXc0harTZ_oDo9xEpmojEN9_qs+qpQ@mail.gmail.com>
References: <1431542014-3239-1-git-send-email-Jason@zx2c4.com>
	<20150513184331.GA1847@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: oss-security <oss-security@lists.openwall.com>,
	shigekatsu.tateno@atmel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150513184331.GA1847@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 13, 2015 at 8:43 PM, Greg KH <greg@kroah.com> wrote:
> Any reason you didn't cc: the maintainer who could actually apply these
> to the kernel tree?

I did, look at the email again: the first recipient is
<shigekatsu.tateno@atmel.com>.

>From the MAINTAINERS file:
    STAGING - OZMO DEVICES USB OVER WIFI DRIVER
    M:      Shigekatsu Tateno <shigekatsu.tateno@atmel.com>
    S:      Maintained
    F:      drivers/staging/ozwpan/
