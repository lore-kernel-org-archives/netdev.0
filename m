From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: Re: [ANN] compat-wireless released based on 3.3-rc6
Date: Fri, 9 Mar 2012 17:05:38 -0800
Message-ID: <CAB=NE6WvhU_sA9RLt7rQQE3pnhw7mpz7hkas9PXZqu-SBaEBOg@mail.gmail.com>
References: <CAB=NE6W98XLxHq-Uom4g0q_bFKaNGJ4WN11x9_9oqWDZFXOy0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org,
	lf_driver_backport@lists.linux-foundation.org,
	Felix Fietkau <nbd@openwrt.org>,
	Kathy Giori <kgiori@qca.qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6W98XLxHq-Uom4g0q_bFKaNGJ4WN11x9_9oqWDZFXOy0g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 9, 2012 at 5:03 PM, Luis R. Rodriguez <mcgrof@frijolero.org> wrote:
> We chug along and are now at 3.3-rc6. We're close to the final release
> so we push out the first Wireless / Bluetooth / Ethernet backport rc
> release based on rc6. We have two releases for this update, a vanilla
> one [0] and a -n release [1] which has 14 patches cherry picked from
> linux-next.git as suggested by nbd as listed below.

Oh and of course, I forgot, the shiny code metrics, which tells you
exactly how much code is from upstream, how much code is backport work
and what code is cherry picked from linux-next.git:

compat-wireless code metrics

    824003 - Total upstream lines of code being pulled
      2482 - backport code changes
      2132 - backport code additions
       350 - backport code deletions
      8910 - backport from compat module
     11392 - total backport code
    1.3825 - % of code consists of backport work
       257 - Code changes brought in from linux-next
       140 - Code additions brought in from linux-next
       117 - Code deletions brought in from linux-next
    0.0312 - % of code being cherry picked from linux-next

Base tree: linux-stable.git
Base tree version: v3.3-rc6
compat-wireless release: compat-wireless-v3.3-rc6-1-n

  Luis
