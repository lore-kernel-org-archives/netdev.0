From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 06 May 2013 19:09:22 -0400 (EDT)
Message-ID: <20130506.190922.168696209163637134.davem@davemloft.net>
References: <20130506.170537.2116026617074159336.davem@davemloft.net>
	<CA+55aFzQ8MzrmPQNPfLFA3nVQVDR3HL+RwcGrAwanJCKRxL2=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzQ8MzrmPQNPfLFA3nVQVDR3HL+RwcGrAwanJCKRxL2=A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 6 May 2013 15:57:15 -0700

> On Mon, May 6, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Just a small pile of fixes:
> 
> Ok, apparently the e1000e problem didn't get fixed yet. Should I just
> revert ce43a2168c59 for now, or do we have a fix for that forthcoming
> shortly?

It is coming very shortly.
