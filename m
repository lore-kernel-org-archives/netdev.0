From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC v5 1/6] Timekeeping cross timestamp interface for device
 drivers
Date: Fri, 8 Jan 2016 10:13:54 +0100
Message-ID: <20160108091354.GB2344@localhost.localdomain>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com>
 <1451911523-8534-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLXThwiibfoxEvWMZWMDTeFi2EqEU6i2tBvF5H89B3Pzxw@mail.gmail.com>
 <op.yav9khd91774gr@chall-mobl2.amr.corp.intel.com>
 <CALAqxLVY=u1S8qy0fox6Fmkkb8yDS3yHu+UioQe9-qNraM7ngQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christopher Hall <christopher.s.hall@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALAqxLVY=u1S8qy0fox6Fmkkb8yDS3yHu+UioQe9-qNraM7ngQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2016 at 05:05:24PM -0800, John Stultz wrote:
> Yea. I just feel like lots of structures add extra abstraction that
> makes the code harder to learn or re-learn. Not only is one trying to
> remember the base types that are being passed around, but you also
> have to remember what all the meta-structures are for. Especially for
> these two-value structures.

FWIW, I had exactly this trouble when reading this series.

Thanks,
Richard
