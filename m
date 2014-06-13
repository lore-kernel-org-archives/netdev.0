From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Fri, 13 Jun 2014 00:53:22 -0700 (PDT)
Message-ID: <20140613.005322.2144989764990353623.davem@davemloft.net>
References: <20140612.121445.484288603919840829.davem@davemloft.net>
	<CA+55aFy=CThoSKAJ6J3Jt-SJDkiGzwg=5tdF7_g+vyTEoPFzMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
	linville@tuxdriver.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ilw@linux.intel.com
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy=CThoSKAJ6J3Jt-SJDkiGzwg=5tdF7_g+vyTEoPFzMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jun 2014 23:48:57 -0700

> On Thu, Jun 12, 2014 at 12:14 PM, David Miller <davem@davemloft.net> wrote:
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> 
> Hmm. I get *lots* of the appended messages from iwlwifi now. Things
> still seem to work, but ...
> 
> This is a Haswell laptop with bog-standard intel wireless:
> 
>   01:00.0 Network controller: Intel Corporation Wireless 7260 (rev 6b)
> 
> Any ideas?

Tom Herbert posted some checksumming fixes today, they might do the
trick.

I'll push them to you tomorrow.

For reference:

http://patchwork.ozlabs.org/patch/359390/
http://patchwork.ozlabs.org/patch/359391/
http://patchwork.ozlabs.org/patch/359392/
http://patchwork.ozlabs.org/patch/359393/
