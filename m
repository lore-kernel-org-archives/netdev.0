From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 1/2 v3] ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT macro and
 cleanup const 63
Date: Thu, 16 Jan 2014 11:08:39 +0800
Message-ID: <CABawtvPJ1ObkwbKjVtzajQnn_181CTo-jmLc0uGY2nqZw9_jtg@mail.gmail.com>
References: <1389795148-341-1-git-send-email-ethan.kernel@gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DA20@ORSMSX101.amr.corp.intel.com>
	<CABawtvNEDjTJAjJ9TeEvZd7+2kD=H6zA23T-aQo3uVm5SUEhCQ@mail.gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DE7D@ORSMSX101.amr.corp.intel.com>
	<CABawtvNSpDU+pjdJOpCB8kyQqA7B9N4g0S_yPgQaZnB3h0+nFg@mail.gmail.com>
	<309B89C4C689E141A5FF6A0C5FB2118B7312DF41@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B7312DF41@ORSMSX101.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron,
    Ok, Dave Miler's net-next tree.

Thanks,
Etan

On Thu, Jan 16, 2014 at 10:51 AM, Brown, Aaron F
<aaron.f.brown@intel.com> wrote:
> On Thu, 2014-01-16 at 09:58 +0800, Ethan Zhao wrote:
>> Aaron,
>>
>> Is this your net-next repo ? if so, I rebuild the patch with this repo
>> right now .
>> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git
>>
>> Thanks,
>> Ethan
>>
> Only sort of.  Jeff uses it to push patches up, but I don't have an
> account there so am simply sending them up the old fashioned way, via
> email, hence it is probably not getting updated while Jeff is out.
>
> As long as your patch can apply cleanly to Dave Miller's net-next tree I
> should be able to pull it into our internal ones.
