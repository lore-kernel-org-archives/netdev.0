From: Greg Dietsche <gregory.dietsche@cuw.edu>
Subject: Re: [PATCH 1/2] iwlegacy: change =?UTF-8?Q?IWL=5FWARN=20to=20IWL?=
 =?UTF-8?Q?=5FDEBUG=5FHT=20in=20iwl=34=39=36=35=5Ftx=5Fagg=5Fstart?=
Date: Sun, 18 Sep 2011 09:41:07 -0500
Message-ID: <06325e16d48ae62d4775167377ee7abe@farmergreg.com>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
 <20110829122013.GA3597@redhat.com> <4E5B9533.6000109@cuw.edu>
 <20110829140032.GA1573@redhat.com> <20110906150131.GA7322@redhat.com>
 <4E683BBE.3060105@cuw.edu> <20110908161129.GC2195@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110908161129.GC2195@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Sep 2011 18:11:30 +0200, Stanislaw Gruszka wrote:

<snip>

> The second patch is ok. I'm not sure about first one, but we can get
> rid of "ctx = il_rxon_ctx_from_vif(vif)" at all, because we have
> only one context. Removing il_rxon_context structure from
> iwlegacy driver is my long term plan, you can look at that
> if you wish.
Sounds good. I'll let you know if I start to remove the il_rxon_context 
structure. It looks right now like I might not have much free time in 
the near future.

Greg
