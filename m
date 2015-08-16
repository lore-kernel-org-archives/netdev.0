From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: recent updates to networking (26b552e0a85ba7e74d384a9624d83118d38071f7)
 cause softlocks
Date: Sat, 15 Aug 2015 22:18:18 -0700
Message-ID: <CAM_iQpXYP7eBomhz_AZjs5aPm764Vm3xoCc82WSL+PubyFtaAA@mail.gmail.com>
References: <55CFF387.2000107@jons.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jon Christopherson <jon@jons.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CFF387.2000107@jons.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(CC'ing netdev)

On Sat, Aug 15, 2015 at 7:20 PM, Jon Christopherson <jon@jons.org> wrote:
> Hello All,
>
> the recent commit (26b552e0a85ba7e74d384a9624d83118d38071f7) causes
> softlocks on my system using the e1000e driver. Kernel builds before this
> commit do not experience the behavior. I have opened a bug report here:
> https://bugzilla.kernel.org/show_bug.cgi?id=102911 with more details.
>

The commit you refer is a merge commit...
