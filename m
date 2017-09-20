From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC V1 net-next 0/6] Time based packet transmission
Date: Wed, 20 Sep 2017 22:11:53 +0200
Message-ID: <20170920201153.d3o3h62y2snuacef@localhost>
References: <cover.1505719061.git.rcochran@linutronix.de>
 <20170920173533.32537-1-levipearson@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rcochran@linutronix.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        vinicius.gomes@intel.com, andre.guedes@intel.com,
        john.stultz@linaro.org, jesus.sanchez-palencia@intel.com,
        henrik@austad.us, tglx@linutronix.de, anna-maria@linutronix.de,
        davem@davemloft.net
To: levipearson@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170920173533.32537-1-levipearson@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 20, 2017 at 11:35:33AM -0600, levipearson@gmail.com wrote:
> Anyway, I am wholly in favor of this proposal--in fact, it is very similar to
> a patch set I shared with Eric Mann and others at Intel in early Dec 2016 with
> the intention to get some early feedback before submitting here. I never heard
> back and got busy with other things. I only mention this since you said
> elsewhere that you got this idea from Eric Mann yourself, and I am curious
> whether Eric and I came up with it independently (which I would not be
> surprised at).

Well, I actually thought of placing the Tx time in a CMSG all by
myself, but later I found Eric's talk from 2012,

  https://linuxplumbers.ubicast.tv/videos/linux-network-enabling-requirements-for-audiovideo-bridging-avb/

and so I wanted to give him credit.

Thanks,
Richard
