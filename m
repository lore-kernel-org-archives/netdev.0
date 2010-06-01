From: reinette chatre <reinette.chatre@intel.com>
Subject: Re: pull request: wireless-2.6 2010-05-28
Date: Tue, 01 Jun 2010 09:22:41 -0700
Message-ID: <1275409361.2091.27208.camel@rchatre-DESK>
References: <20100528180952.GC2405@tuxdriver.com>
	 <AANLkTil8SLseSeq1M_Xg7P4AqMy3V_0jxc7by2Xuaqnb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Zheng, Jiajia" <jiajia.zheng@intel.com>,
	"Kolekar, Abhijeet" <abhijeet.kolekar@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTil8SLseSeq1M_Xg7P4AqMy3V_0jxc7by2Xuaqnb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sedat,

On Sat, 2010-05-29 at 06:34 -0700, Sedat Dilek wrote:
> Two people confirmed the patch in [2] fixes:
> 1. iwlwifi-2.6 GIT master (commit f10a237c95abd6d64a3a24553bd1d3bcddd9108b)
> 2. compat-wireless (2010-05-21)
> 
> And it fixes also the above mentionned combination.

We are working on getting this patch upstream. The version tested
contains a significant amount of duplicated code as well as some cleanup
code mixed in. It is thus not appropriate for an upstream submission at
this time.

> As a suggestion:
> What about "copying" bug-reports (incl. its history) from IWL-BTS into
> linux-wireless ML?
> For example (dri-devel related) bug-reports from
> bugzilla.freedesktop.org are "copied" into dri-devel ML.

Pointing people to the bug report seems to work ok. What benefit does
the above have?

Reinette
