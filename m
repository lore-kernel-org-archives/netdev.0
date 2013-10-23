From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 11/11] asmlinkage, wan/sbni: Make inline assembler
 symbols visible and assembler global
Date: Wed, 23 Oct 2013 04:22:30 +0200
Message-ID: <20131023022230.GI29695@two.firstfloor.org>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
 <1382458346-24811-12-git-send-email-andi@firstfloor.org>
 <20131022.135928.2040131908206663695.davem@davemloft.net>
 <20131023020955.GF29695@two.firstfloor.org>
 <CAGVrzcZ6xgp4TMgwDFJwz45m8narx0sHYAyM67HsD069tFg3BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ak@linux.intel.com, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcZ6xgp4TMgwDFJwz45m8narx0sHYAyM67HsD069tFg3BA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How about scheduling the WAN drivers for removal? Does anybody
> actually use them nowadays?

Perhaps at least the ISA devices? ISA hardware should be nearing
end of live by now.

Looking at the git log there doesn't seem to be any real changes,
other than tree sweeps or build fixes.

But I must admit I don't really know much about them.

-Andi
