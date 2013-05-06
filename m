From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 6 May 2013 15:57:15 -0700
Message-ID: <CA+55aFzQ8MzrmPQNPfLFA3nVQVDR3HL+RwcGrAwanJCKRxL2=A@mail.gmail.com>
References: <20130506.170537.2116026617074159336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130506.170537.2116026617074159336.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 6, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
>
> Just a small pile of fixes:

Ok, apparently the e1000e problem didn't get fixed yet. Should I just
revert ce43a2168c59 for now, or do we have a fix for that forthcoming
shortly?

             Linus
