From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 12:49:52 -0700
Message-ID: <20160718194952.GM5871@two.firstfloor.org>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
 <CAKgT0UfA6ShdVta615ZqH8WvedgxSd3SjA5nZ+5EZGROWYa_sg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07712C19831@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"decot@googlers.com" <decot@googlers.com>,
	"Brandeburg, J
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07712C19831@SHSMSX103.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > So where is your policy for power saving?  From past experience I can tell you
> 
> There is no policy for power saving yet. I will add it to my todo list.

Yes it's interesting to consider. The main goal here is to maximize CPU
idle residency? I wonder if that's that much different from the CPU policy.

-Andi
